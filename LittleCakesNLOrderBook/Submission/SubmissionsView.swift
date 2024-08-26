import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct SubmissionsView: View {
    @StateObject private var viewModel = SubmissionsViewModel()

    var body: some View {
        NavigationView {
            List {
                let groupedSubmissions = viewModel.groupedSubmissions()
                let sortedDates = groupedSubmissions.keys.sorted(by: >)
                
                ForEach(sortedDates, id: \.self) { date in
                    Section(header: Text(dateFormatted(date: date))) {
                        if let submissionsForDate = groupedSubmissions[date] {
                            ForEach(submissionsForDate) { submission in
                                SubmissionRowView(submission: submission, viewModel: viewModel)
                            }
                        }
                    }
                }
            }
            .refreshable {
                viewModel.fetchSubmissions()
            }
            .navigationTitle("Orders")
            .onAppear {
                viewModel.fetchSubmissions()
            }
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
        ) {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("\(viewModel.fetchSubmissionCustomerName(submission)) - \(viewModel.fetchSubmissionCustomerPickupLocation(submission))")
                        .font(.headline)
                        .lineLimit(1)
                    Text(viewModel.fetchSubmissionCakeDescription(submission))
                        .font(.caption)
                        .lineLimit(nil)
                    Text("Date: \(viewModel.fetchSubmissionPickupDate(submission))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                    if let submissionTime = submission.submissionTimeDate {
                        Text("Created: \(submissionTime, formatter: submissionDateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                buildImages()
            }
            .cornerRadius(8)
        }
        
        .background(submission.isConfirmed ? Color.green.opacity(0.3) : Color.clear)
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


