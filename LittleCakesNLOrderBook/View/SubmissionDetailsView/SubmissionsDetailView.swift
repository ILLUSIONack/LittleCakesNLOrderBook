import Foundation
import SwiftUI
import Firebase
import EventKit
import EventKitUI

struct SubmissionDetailView: View {
    @ObservedObject var viewModel: SubmissionsViewModel
    @State private var calendarEventSaved = false
    @State private var showConfirmationAlert = false
    @State private var editedSubmission: MappedSubmission
    @State private var showSaveAlert = false
    @State private var isEditEnabled = false
    
    @State private var showEventEditView = false
    @State private var event: EKEvent?

    private let eventStore = EventStoreManager.shared
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    init(submission: MappedSubmission, viewModel: SubmissionsViewModel) {
        self._editedSubmission = State(initialValue: submission)
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            List(Array(editedSubmission.questions.enumerated()), id: \.element.id) { index, question in
                if let valueType = question.value {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(question.name)
                            .font(.headline)
        
                        switch valueType {
                        case .array(let list):
                            if isEditEnabled {
                                buildTextField(list: list, index: index)
                            } else {
                                buildText(list: list)
                            }
                        case .file(let file):
                            buildFile(list: file)
                        case .string(let text):
                            if question.name == Questions.name.rawValue {
                                if !isEditEnabled, let instaText = text {
                                    Button(action: { openInstagramProfile(instagramName: instaText) }
                                    ) {
                                        Text(instaText)
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                } else {
                                    TextField(
                                        "Instagram Name",
                                        text: Binding(
                                            get: { editedSubmission.questions[index].value?.stringValue ?? "" },
                                            set: { newValue in
                                                editedSubmission.questions[index].value = .string(newValue)
                                            }
                                        )
                                    )
                                }
                            } else {
                                if isEditEnabled {
                                    TextEditor(text: Binding(
                                        get: { editedSubmission.questions[index].value?.stringValue ?? "" },
                                        set: { newValue in
                                            editedSubmission.questions[index].value = .string(newValue)
                                        }
                                    ))
                                    .frame(minHeight: 20)
                                } else {
                                    if let text = editedSubmission.questions[index].value?.stringValue {
                                        Button(action: {
                                            UIPasteboard.general.string = text
                                            feedbackGenerator.impactOccurred()
                                        }) {
                                            buildText(stringItem: text)
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                }
                            }
                        case .null:
                            EmptyView()
                        }
                    }
                }
            }
            .navigationTitle("Submission Details")

            HStack {
                if isEditEnabled {
                    Button(action: {
                        saveChangesToFirebase()
                    }) {
                        Text("Save Changes")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showSaveAlert) {
                        Alert(title: Text("Success"), message: Text("Changes saved successfully!"), dismissButton: .default(Text("OK")))
                    }
                } else {
                    Button(action: {
                        requestCalendarAccess { granted in
                            if granted {
                                var eventTitle: String?
                                if let name = viewModel.fetchSubmissionWithQuestion(editedSubmission, .name),
                                   let pickupLocation = viewModel.fetchSubmissionWithQuestion(editedSubmission, .pickupLocation) {
                                    eventTitle = "\(name) - \(pickupLocation)"
                                }
                                
                                let startDate = viewModel.fetchSubmissionPickupDateAsDate(editedSubmission)
                                let endDate = startDate.addingTimeInterval(3600 * 3)
                                
                                createEvent(title: eventTitle ?? "", startDate: startDate, endDate: endDate)
                                
                            } else {
                                print("Calendar access denied")
                            }
                        }
                    })  {
                        Text(editedSubmission.isConfirmed || showConfirmationAlert ? "Order Confirmed" : "Confirm Order")
                            .foregroundColor(.white)
                            .padding()
                            .background(editedSubmission.isConfirmed || showConfirmationAlert ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(editedSubmission.isConfirmed || showConfirmationAlert)
                }
            }
        }
        .alert(isPresented: $calendarEventSaved) {
            Alert(title: Text("Success"), message: Text("Event added to your calendar!"), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showEventEditView) {
            if let event = event {
                EventEditViewController(eventStore: eventStore, event: event) {
                    print("Cofnirm")
                    viewModel.confirmSubmission(withId: editedSubmission.submissionId)
                    calendarEventSaved = false
                    showConfirmationAlert = true
                } onCancel: {
                    print("Canceled")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditEnabled.toggle() }) {
                    Image(systemName: "pencil")
                }
            }
        }
    }
    
    @ViewBuilder
    func buildText(list: [String]) -> some View {
        ForEach(list, id: \.self) { stringItem in
            Text(stringItem)
                .padding()
        }
    }
    
    func buildText(stringItem: String) -> some View {
        Text(stringItem)
            .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func buildTextField(list: [String], index: Int) -> some View {
        ForEach(list.indices, id: \.self) { itemIndex in
            TextField(
                "Item \(itemIndex + 1)",
                text: Binding(
                    get: { list[itemIndex] },
                    set: { newValue in
                        editedSubmission.questions[index].value = .array(list.enumerated().map { $0.offset == itemIndex ? newValue : $0.element })
                    }
                )
            )
        }
    }
    
    @ViewBuilder
    func buildFile(list: [File]) -> some View {
        ForEach(list, id: \.self) { file in
            if let cachedImage = viewModel.getCachedImage(for: file) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else {
                AsyncImage(url: URL(string: file.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    ProgressView()
                }
                .padding()
            }
        }
    }
    
    private func openInstagramProfile(instagramName: String) {
        let urlString = "https://www.instagram.com/\(instagramName)/"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            if let error = error {
                print("Error requesting access to calendar: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }
    
    private func createEvent(title: String, startDate: Date, endDate: Date) {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = title
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        showEventEditView = true

        do {
            try eventStore.save(newEvent, span: .thisEvent)
            event = newEvent
        } catch let error {
            print("Failed to save event: \(error.localizedDescription)")
        }
    }
    
    private func saveChangesToFirebase() {
        viewModel.updateSubmission(editedSubmission) { result in
            switch result {
            case .success:
                print("Submission updated successfully.")
                feedbackGenerator.impactOccurred()
                isEditEnabled = false
            case .failure(let error):
                print("Failed to update submission: \(error.localizedDescription)")
            }
        }
    }
}

struct EventEditViewController: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    let event: EKEvent
    var onSave: () -> Void
    var onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.onSave = onSave
        coordinator.onCancel = onCancel
        return coordinator
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventEditVC = EKEventEditViewController()
        eventEditVC.eventStore = eventStore
        eventEditVC.event = event
        eventEditVC.editViewDelegate = context.coordinator
        return eventEditVC
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // No need to update anything here
    }
}

final class Coordinator: NSObject, EKEventEditViewDelegate {
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true) {
            switch action {
            case .saved:
                self.onSave?()
            case .canceled:
                self.onCancel?()
            default:
                break
            }
        }
    }
}
