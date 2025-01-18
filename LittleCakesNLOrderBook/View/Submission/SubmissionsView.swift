import SwiftUI

struct SubmissionsView: View {
    
    @ObservedObject var firestoreManager: FirestoreManager
    @ObservedObject var authenticationManager: AuthenticationManager
    @StateObject private var viewModel: SubmissionsViewModel
    
    @State private var searchText: String = ""
    @State private var isSearchBarVisible: Bool = false
    @FocusState private var isSearchBarFocused: Bool
    
    init(
        authenticationManager: AuthenticationManager,
        filloutService: FilloutService
    ) {
        self.firestoreManager = authenticationManager.firestoreManager
        self.authenticationManager = authenticationManager
        _viewModel = StateObject(
            wrappedValue:
                SubmissionsViewModel(
                    firestoreManager: authenticationManager.firestoreManager,
                    authenticationManager: authenticationManager,
                    filloutService: filloutService
                )
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    
                    .overlay(alignment: .bottom, content: {
                        if viewModel.isShowTodayButtonVisible {
                            buildShowTodayButton(scrollViewProxy: scrollViewProxy)
                        }
                    })
                    .overlay(alignment: .top, content: {
                        if viewModel.newSubmissionsCount > 0 {
                            Button(action: {
                                viewModel.newSubmissionsCount = 0
                                viewModel.generateFeedback(style: .medium)
                                viewModel.getSubmissionByType(field: "type", value: viewModel.submissionType.rawValue)
                            }) {
                                Text("\(viewModel.newSubmissionsCount) new submissions added")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    })
                    
                }
                .if(isSearchBarVisible) { view in
                    view.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
                }
                .onChange(of: searchText) { newValue in
                    viewModel.filterSubmissions(by: newValue)
                }
                .refreshable {
                    viewModel.generateFeedback(style: .medium)
                    viewModel.getSubmissionByType(field: "type", value: viewModel.submissionType.rawValue)
                }
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // First ToolbarItem: Filter Menu
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
                            //                    Button(action: {
                            //                        viewModel.getSubmissionByType(field: "state", value: SubmissionState.unviewed.rawValue)
                            //                    }) {
                            //                        Label("Unread", systemImage: "book.pages")
                            //                    }
                        } label: {
                            Image(systemName: "camera.filters")
                        }
                        .tint(Color.black)
                    }
                    
                    // Second ToolbarItem: Search Button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            searchText = ""
                            isSearchBarVisible.toggle()
                            viewModel.filterSubmissions(by: "")
                            isSearchBarFocused = isSearchBarVisible
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                        .tint(Color.black)
                        
                    }
                    
                    // Third ToolbarItem: Sign Out Button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.signOut()
                        }) {
                            Image(systemName: "door.left.hand.open")
                        }
                        .tint(Color.black)
                    }
                }
                loadingView
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        if viewModel.isLoading {
            Color.white
            VStack(spacing: 8) {
                LottieView(animationName: "skeletonLoading")
                LottieView(animationName: "skeletonLoading")
                LottieView(animationName: "skeletonLoading")
                LottieView(animationName: "skeletonLoading")
                LottieView(animationName: "skeletonLoading")
            }
            .padding([.horizontal, .bottom], 8)
        }
    }
    
    private func buildShowTodayButton(scrollViewProxy: ScrollViewProxy) -> some View {
        Button(action: {
            scrollToToday(scrollViewProxy: scrollViewProxy)
        }) {
            Text("Go to Today")
                .padding([.horizontal, .vertical], 8)
                .font(.headline)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func buildSectionHeader(for date: Date) -> some View {
        let isToday = Calendar.current.isDate(date, inSameDayAs: viewModel.today)
        
        Text(viewModel.dateFormatted(date: date))
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
                    Button(role: .destructive) {
                        viewModel.markSubmissionAsCompleted(submission)
                    } label: {
                        Label("Complete", systemImage: "checkmark.seal")
                    }
                    .tint(.green)
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
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
