import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct ContentView: View {

    var body: some View {
        TabView {
            SubmissionsView(submissionState: .new)
                .tabItem {
                    Image(systemName: "arrow.down.circle")
                    Text("New")
                }
            SubmissionsView(submissionState: .orders)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
            SubmissionsView(submissionState: .confirmed)
                .tabItem {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Confirmed")
                }
            SubmissionsView(submissionState: .completed)
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Completed")
                }
            SubmissionsView(submissionState: .deleted)
                .tabItem {
                    Image(systemName: "arrow.up.trash.fill")
                    Text("Deleted")
                }
        }
    }
}

struct SubmissionsView: View {
    @StateObject private var viewModel = SubmissionsViewModel()
    let submissionState: SubmissionState
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else {
                    List {
                        if viewModel.isNewOrdersViewVisible {
                            Text(viewModel.newOrdersText)
                                .frame(minWidth: 400)
                                .font(Font.footnote.weight(.bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        }
//                                        let groupedSubmissions = viewModel.groupedSubmissions()
                        let sortedDates = viewModel.groupedSubmissions.keys.sorted(by: >)
                        
                        ForEach(sortedDates, id: \.self) { date in
                            Section(header: Text(dateFormatted(date: date))) {
                                if let submissionsForDate = viewModel.groupedSubmissions[date] {
                                    ForEach(submissionsForDate) { submission in
                                        HStack {
                                            if !submission.isViewed {
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 8, height: 8)
                                            } else {
                                                ZStack {
                                                    Color.clear
                                                        .frame(width: 8, height: 8)
                                                    
                                                }
                                                .frame(width: 8, height: 8)
                                            }
                                            SubmissionRowView(submission: submission, viewModel: viewModel)
                                            
                                                .swipeActions {
                                                    if !submission.isDeleted  {
                                                        Button(role: .destructive) {
                                                            viewModel.markSubmissionAsDeleted(submission)
                                                            viewModel.fetchSubmissions(state: submissionState)
                                                        } label: {
                                                            Label("Delete", systemImage: "trash")
                                                        }
                                                    }
                                                    if !submission.isCompleted {
                                                        Button(role: .cancel) {
                                                            viewModel.markSubmissionAsCompleted(submission)
                                                        } label: {
                                                            Label("Complete", systemImage: "checkmark.seal")
                                                        }
                                                    }
                                                }
                                        }
                                        .listRowBackground(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(submission.isConfirmed ? Color.green : Color.clear, lineWidth: 5)
                                                .background(Color.white) // Ensure the background is set
                                        )
//                                                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                viewModel.fetchSubmissions(state: submissionState, onAppear: false)
            }
            .onAppear {
                viewModel.fetchSubmissions(state: submissionState, onAppear: true)
                viewModel.getGroupedSubmissions()
            }
            .onDisappear {
                viewModel.stopPolling()
            }
            .navigationTitle(viewModel.title)
        }
    }

    func dateFormatted(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
}

struct SubmissionRowView: View {
    let submission: MappedSubmission
    @ObservedObject var viewModel: SubmissionsViewModel

    var body: some View {
        NavigationLink(destination:
                        SubmissionDetailView(
                            submission: submission,
                            viewModel: viewModel
                        )
                            .onAppear {
                                // Mark the submission as viewed when detail view appears
                                viewModel.markSubmissionAsViewed(submission)
                            }
        ) {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("\(viewModel.fetchSubmissionCustomerName(submission)) - \(viewModel.fetchSubmissionCustomerPickupLocation(submission))")
                        .font(.headline)
                        .lineLimit(1)
                    if let cakeSizeText = viewModel.fetchSubmissionWithQuestion(submission, questionString: "For how many people would you like the cake?"), let cake = viewModel.fetchSubmissionWithQuestion(submission, questionString: "Which shape would you like your cake?") {
                        Text("- \(cakeSizeText) / \(cake)")
                            .font(.caption)
                            .lineLimit(nil)
                    }
                    
                    if let heartCakeSizeText = viewModel.fetchSubmissionWithQuestion(submission, questionString: "For how many people would you like the cake? (1)") , let cake = viewModel.fetchSubmissionWithQuestion(submission, questionString: "Which shape would you like your cake?") {
                        Text("- \(heartCakeSizeText) / \(cake)")
                            .font(.caption)
                            .lineLimit(nil)
                    }
                    
                    if let flavourText = viewModel.fetchSubmissionWithQuestion(submission, questionString: "Which flavour would you like the cake?") {
                        Text("- \(flavourText)")
                            .font(.caption)
                            .lineLimit(nil)
                    }
                    
                    if let fillingText = viewModel.fetchSubmissionWithQuestion(submission, questionString: "Which flavour would you like the filling?") {
                        Text("- \(fillingText)")
                            .font(.caption)
                            .lineLimit(nil)
                    }
                    
                    
                    if let cakeText = viewModel.fetchSubmissionWithQuestion(submission, questionString: "Which text would you like on the cake and which colour?"), 
                        let writtenText = viewModel.fetchSubmissionWithQuestion(submission, questionString: "How would you like the text?") {
                        Text("- \(cakeText) / \(writtenText)")
                            .font(.caption)
                            .lineLimit(nil)
                    }
                    

                    HStack {
                        if let submissionTime = submission.submissionTimeDate {
                            Text("Created: \(submissionTime, formatter: submissionDateFormatter)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        if let daysAgo = viewModel.getDaysAgo(submissionDate: submission.submissionTimeDate), !submission.isConfirmed {
                            Text(daysAgo)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                buildImages()
            }
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    func buildImages() -> some View {
        ForEach(submission.questions, id: \.self) { questions in
            if case .file(let filesList) = questions.value {
                buildFile(list: [filesList[0]])
            }
        }
    }
    
    @ViewBuilder
    func buildFile(list: [File]) -> some View {
        ForEach(list, id: \.self) { file in
            if let cachedImage = ImageCache.shared.object(forKey: NSURL(string: file.url)! as NSURL) {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    
            } else {
                // Fallback to AsyncImage if not cached
                AsyncImage(url: URL(string: file.url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                } placeholder: {
                    ZStack {
                        Color.clear
                            .frame(width: 64, height: 64)

                        ProgressView()
                    }
                    .frame(width: 64, height: 64)
                }
            }
        }
    }
    
    private let submissionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
//        formatter.timeStyle = .short
        return formatter
    }()
}


