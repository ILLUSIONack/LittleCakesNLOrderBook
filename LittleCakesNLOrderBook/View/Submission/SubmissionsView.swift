import SwiftUI

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

struct ContentView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: ContentViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ContentViewModel(firestoreManager: FirestoreManager.shared))
    }
    var body: some View {
        TabView {
            SubmissionsView(submissionState: .orders, firestoreManager: firestoreManager)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Orders")
                }
            if viewModel.isConfirmedTabVisible {
                SubmissionsView(submissionState: .confirmed, firestoreManager: firestoreManager)
                    .tabItem {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Confirmed")
                    }
            }
            if viewModel.isCompletedTabVisible {
                SubmissionsView(submissionState: .completed, firestoreManager: firestoreManager)
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Completed")
                    }
            }
            if viewModel.isDeletedTabVisible {
                SubmissionsView(submissionState: .deleted, firestoreManager: firestoreManager)
                    .tabItem {
                        Image(systemName: "arrow.up.trash.fill")
                        Text("Deleted")
                    }
            }
        }
        .onAppear {
            viewModel.fetchSubmissions()
        }
    }
}

struct SubmissionsView: View {
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @StateObject private var viewModel: SubmissionsViewModel
    let submissionState: SubmissionState
    @State private var searchText: String = ""
    @State private var isSearchBarVisible: Bool = false
    @FocusState private var isSearchBarFocused: Bool
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    private let today = Date()

    init(submissionState: SubmissionState, firestoreManager: FirestoreManager) {
        _viewModel = StateObject(wrappedValue: SubmissionsViewModel(firestoreManager: firestoreManager))
        self.submissionState = submissionState
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        buildSearchBar()
                        buildNewOrdersView()

                        ScrollViewReader { scrollViewProxy in
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
                    }
                }
            }
            .refreshable {
                feedbackGenerator.impactOccurred()
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
            .toolbar {
                if submissionState == .orders {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.filterNewButtonPressed) {
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
    private func buildNewOrdersView() -> some View {
        if viewModel.isNewOrdersViewVisible {
            Text(viewModel.newOrdersText)
                .frame(minWidth: 400)
                .font(Font.footnote.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
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
    }
    
    @ViewBuilder
    private func buildSubmissionRowView(_ submission: MappedSubmission) -> some View {
        SubmissionRowView(submission: submission, viewModel: viewModel)
            .swipeActions {
                if !submission.isDeleted {
                    Button(role: .destructive) {
                        viewModel.markSubmissionAsDeleted(submission, state: true)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                if submission.isDeleted {
                    Button(role: .destructive) {
                        viewModel.markSubmissionAsDeleted(submission, state: false)
                    } label: {
                        Label("Undelete", systemImage: "trash")
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

    func dateFormatted(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
}
