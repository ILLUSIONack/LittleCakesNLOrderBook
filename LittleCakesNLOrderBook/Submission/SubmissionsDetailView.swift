import Foundation
import SwiftUI
import EventKit

struct SubmissionDetailView: View {
    let submission: MappedSubmission
    @ObservedObject var viewModel: SubmissionsViewModel
    @State private var calendarEventSaved = false
    @State private var showConfirmationAlert = false
    
    var body: some View {
        VStack {
            List(submission.questions) { question in
                if let valueType = question.value {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(question.name)
                            .font(.headline)
                        
                        switch valueType {
                        case .array(let list):
                            buildText(list: list)
                        case .file(let file):
                            buildFile(list: file)
                        case .string(let text):
                            if let text = text {
                                if question.name == "What's your instagram name?" {
                                    Button(action: { openInstagramProfile(instagramName: text) }) {
                                        Text(text)
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                } else {
                                    Text(text)
                                        .padding()
                                }
                            }
                        case .null:
                            EmptyView()
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Submission Details")
            
            Button(action: {
                requestCalendarAccess { granted in
                    if granted {
                        let eventTitle = "\(viewModel.fetchSubmissionCustomerName(submission)) - \(viewModel.fetchSubmissionCustomerPickupLocation(submission))"
                        
                        let startDate = viewModel.fetchSubmissionPickupDateAsDate(submission)
                        let endDate = startDate.addingTimeInterval(3600 * 3) 
                        
                        addEventToCalendar(title: eventTitle, startDate: startDate, endDate: endDate) { success, error in
                            if success {
                                print("Event saved to calendar")
                                calendarEventSaved = true
                                viewModel.confirmSubmission(withId: submission.submissionId)
                            } else if let error = error {
                                print("Failed to save event: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("Calendar access denied")
                    }
                }
            }) {
                Text(submission.isConfirmed ? "Order Confirmed" : "Confirm Order")
                    .foregroundColor(.white)
                    .padding()
                    .background(submission.isConfirmed ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(submission.isConfirmed)
        }
        .alert(isPresented: $calendarEventSaved) {
            Alert(title: Text("Success"), message: Text("Event added to your calendar!"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func openInstagramProfile(instagramName: String) {
        let urlString = "https://www.instagram.com/\(instagramName)/"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @ViewBuilder
    func buildText(list: [String]) -> some View {
        ForEach(list, id: \.self) { stringItem in
            Text(stringItem)
                .padding()
        }
    }
    
    @ViewBuilder
    func buildFile(list: [File]) -> some View {
        ForEach(list, id: \.self) { file in
            if let cachedImage = ImageCache.shared.object(forKey: NSURL(string: file.url)! as NSURL) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } else {
                // Fallback to AsyncImage if not cached
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
    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if let error = error {
                print("Error requesting access to calendar: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(granted)
        }
    }
    
    func addEventToCalendar(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        let eventStore = EKEventStore()
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
}
