import SwiftUI

struct SubmissionsView: View {
    
    @ObservedObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: SubmissionsViewModel
    
    @State private var searchText: String = ""
    @State private var isSearchBarVisible: Bool = false
    @FocusState private var isSearchBarFocused: Bool
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    private let today = Date()
    
    init(firestoreManager: FirestoreManager, filloutService: FilloutService) {
        self.firestoreManager = firestoreManager
//        self.viewModel = SubmissionsViewModel(firestoreManager: firestoreManager, filloutService: filloutService)
        _viewModel = StateObject(wrappedValue: SubmissionsViewModel(firestoreManager: firestoreManager, filloutService: filloutService))
//        self.viewModel = SubmissionsViewModel(firestoreManager: firestoreManager, filloutService: filloutService)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollViewReader { scrollViewProxy in
                    buildSearchBar()
                    
                    List(viewModel.groupedSubmissions.keys.sorted(by: <), id: \.self) { date in
                        Section(header: buildSectionHeader(for: date)) {
                            if let submissionsForDate = viewModel.groupedSubmissions[date] {
                                ForEach(submissionsForDate) { submission in
                                    HStack(spacing: 8) {
                                        buildIsViewedView(submission)
                                        buildSubmissionRowView(submission)
                                    }
                                    .padding(.horizontal, 0)
                                }
                            }
                        }
                        .id(date)
                    }
                    .listStyle(.grouped)
                    
                    if viewModel.isShowTodayButtonVisible {
                        buildShowTodayButton(scrollViewProxy: scrollViewProxy)
                    }
                }
                
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                }
            }
        .refreshable {
            feedbackGenerator.impactOccurred()
            viewModel.fetchSubmissions()
        }
        .onAppear {
            viewModel.getSubmissionByType(field: "type", value: viewModel.submissionType.rawValue)
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        viewModel.submissionType = .new
                        viewModel.getSubmissionByType(field: "type", value: SubmissionType.new.rawValue)
                    }) {
                        Label("New", systemImage: "star")
                    }
                    Button(action: {
                        viewModel.submissionType = .confirmed
                        viewModel.getSubmissionByType(field: "type", value: SubmissionType.confirmed.rawValue)
                        
                    }) {
                        Label("Confirmed", systemImage: "checkmark.seal")
                    }
                    Button(action: {
                        viewModel.submissionType = .completed
                        viewModel.getSubmissionByType(field: "type", value: SubmissionType.completed.rawValue)
                    }) {
                        Label("Completed", systemImage: "flag.checkered")
                    }
                    Button(action: {
                        viewModel.submissionType = .deleted
                        viewModel.getSubmissionByType(field: "type", value: SubmissionType.deleted.rawValue)
                    }) {
                        Label("Deleted", systemImage: "delete.left.fill")
                    }
                    
                    Button(action: {
                        viewModel.getSubmissionByType(field: "state", value: SubmissionState.unviewed.rawValue)
                    }) {
                        Label("Unread", systemImage: "book.pages")
                    }
                } label: {
                    Image(systemName: "camera.filters")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    searchText = ""
                    isSearchBarVisible.toggle()
                    viewModel.filterSubmissions(by: "")
                    isSearchBarFocused = isSearchBarVisible
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
}
    
    private func buildShowTodayButton(scrollViewProxy: ScrollViewProxy) -> some View {
        Button(action: {
            scrollToToday(scrollViewProxy: scrollViewProxy)
        }) {
            Text("Go to Today")
                .frame(height: 36)
                .font(.headline)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func buildSectionHeader(for date: Date) -> some View {
        let isToday = Calendar.current.isDate(date, inSameDayAs: today)
        
        Text(dateFormatted(date: date))
            .padding(.top, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isToday ? Color.gray.opacity(0.2) : Color.clear)
            .foregroundColor(.primary)
            .fontWeight(isToday ? .bold : .regular)
    }
    
    private func scrollToToday(scrollViewProxy: ScrollViewProxy) {
        scrollViewProxy.scrollTo(viewModel.dateKey, anchor: .center)
    }
    
    @ViewBuilder
    private func buildSearchBar() -> some View {
        if isSearchBarVisible {
            HStack {
                TextField("Search by name", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
                    .focused($isSearchBarFocused)
                    .onChange(of: searchText) { newValue in
                        viewModel.filterSubmissions(by: newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    @ViewBuilder
    private func buildIsViewedView(_ submission: MappedSubmission) -> some View {
        if submission.state == .unviewed {
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
    }
    
    @ViewBuilder
    private func buildSubmissionRowView(_ submission: MappedSubmission) -> some View {
        SubmissionRowView(submission: submission, viewModel: viewModel)
            .swipeActions {
                if submission.type != .deleted {
                    Button(role: .destructive) {
                        viewModel.markSubmissionAsDeleted(submission, type: .deleted)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                if submission.type == .deleted {
                    Button(role: .destructive) {
                        viewModel.markSubmissionAsDeleted(submission, type: .new)
                    } label: {
                        Label("Undelete", systemImage: "trash")
                    }
                }
                if submission.type != .completed  {
                    Button(role: .cancel) {
                        viewModel.markSubmissionAsCompleted(submission)
                    } label: {
                        Label("Complete", systemImage: "checkmark.seal")
                    }
                }
            }
            .swipeActions(edge: .leading) {
                if submission.state != .messaged && submission.type == .new {
                    Button(role: .cancel) {
                        viewModel.markSubmissionAsMessaged(submission)
                    } label: {
                        Label("Messaged", systemImage: "eye")
                    }
                }
            }
    }
    
    func dateFormatted(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
}
