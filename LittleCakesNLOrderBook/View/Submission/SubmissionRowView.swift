import SwiftUI

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
                                viewModel.markSubmissionAsViewed(submission)
                            }
        ) {
            VStack(alignment: .leading, spacing: 0){
                if let name = viewModel.fetchSubmissionWithQuestion(submission, .name),
                    let pickUpLocation = viewModel.fetchSubmissionWithQuestion(submission, .pickupLocation) {
                    Text("\(name) - \(pickUpLocation)")
                        .font(.headline)
                        .lineLimit(1)
                }
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                            
                        if let cakeSizeText = viewModel.fetchSubmissionWithQuestion(submission, .orderSize),
                            let cake = viewModel.fetchSubmissionWithQuestion(submission, .orderShape) {
                            Text("- \(cakeSizeText) / \(cake)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                        
                        if let heartCakeSizeText = viewModel.fetchSubmissionWithQuestion(submission, .orderSize1) ,
                            let cake = viewModel.fetchSubmissionWithQuestion(submission, .orderShape) {
                            Text("- \(heartCakeSizeText) / \(cake)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                        
                        if let flavourText = viewModel.fetchSubmissionWithQuestion(submission, .cakeFlavour) {
                            Text("- \(flavourText)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                        
                        if let flavourText1to4 = viewModel.fetchSubmissionWithQuestion(submission, .cakeFlavour1to4) {
                            Text("- \(flavourText1to4)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                        
                        if let fillingText = viewModel.fetchSubmissionWithQuestion(submission, .cakeFilling) {
                            Text("- \(fillingText)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                        
                        if let fillingText1to4 = viewModel.fetchSubmissionWithQuestion(submission, .cakeFilling1to4) {
                            Text("- \(fillingText1to4)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                        
                        if let cakeText = viewModel.fetchSubmissionWithQuestion(submission, .cakeTextAndColor),
                           let writtenText = viewModel.fetchSubmissionWithQuestion(submission, .cakeTextType) {
                            Text("- \(cakeText) / \(writtenText)")
                                .font(.caption)
                                .lineLimit(nil)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    buildImages()
                }
                HStack {
                    if let submissionTime = submission.submissionTimeDate {
                        Text("Created: \(submissionTime, formatter: submissionDateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    if let daysAgo = viewModel.getDaysAgo(submissionDate: submission.submissionTimeDate),
                       !submission.isConfirmed, !submission.isCompleted, !submission.isDeleted {
                        Text(daysAgo)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                
                if submission.isCompleted {
                    Text("Completed")
                        .font(.footnote)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                } else if submission.isConfirmed {
                    Text("Confirmed")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                    
                } else if submission.isDeleted {
                    Text("Deleted")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
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
        return formatter
    }()
}
