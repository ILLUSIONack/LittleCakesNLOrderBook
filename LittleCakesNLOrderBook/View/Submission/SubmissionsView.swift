import SwiftUI

struct SubmissionsView: View {
    
    @ObservedObject var firestoreManager: FirestoreManager
    @ObservedObject var authenticationManager: AuthenticationService
    @StateObject private var viewModel: SubmissionsViewModel
    
    init(
        authenticationManager: AuthenticationService,
        filloutService: FilloutService,
        isDelegated: Bool = false
    ) {
        self.firestoreManager = authenticationManager.firestoreManager
        self.authenticationManager = authenticationManager
        _viewModel = StateObject(
            wrappedValue:
                SubmissionsViewModel(
                    firestoreManager: authenticationManager.firestoreManager,
                    authenticationManager: authenticationManager,
                    filloutService: filloutService,
                    isDelegated: isDelegated
                )
        )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isFilterViewVisible {
                    filterView
                }
                ScrollViewReader { scrollViewProxy in
                    contentView
                        .overlay(alignment: .bottom, content: {
                            todayButtonView(scrollViewProxy: scrollViewProxy)
                        })
                    
                }
                .overlay(alignment: .top, content: {
                    newSubmissionsBanner
                })
            }
            .toolbar {
                toolbar
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .if(viewModel.isSearchBarVisible) { view in
            view.searchable(
                text: $viewModel.searchText,
                isPresented: $viewModel.isSearchBarVisible,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: LocalizedStringKey("Search")
            )
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            viewModel.filterSubmissions(by: newValue)
        }
        .onDisappear {
            viewModel.isSearchBarVisible = false
        }
    }
    
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: {
                viewModel.searchText = ""
                viewModel.isSearchBarVisible.toggle()
            }) {
                Image(systemName: "magnifyingglass")
            }
            .tint(Color.black)
            Button(action: viewModel.signOut) {
                Image(systemName: "door.left.hand.open")
            }
            .tint(Color.black)
        }
    }
    
    private var contentView: some View {
        ZStack {
            List(viewModel.groupedSubmissions.keys.sorted(by: <), id: \.self) { date in
                Section(header: sectionDateHeaderView(for: date)) {
                    if let submissionsForDate = viewModel.groupedSubmissions[date] {
                        ForEach(submissionsForDate) { submission in
                            HStack(spacing: 8) {
                                notificationIndicatorView(submission)
                                submissionRowView(submission)
                            }
                            .padding(.horizontal, 0)
                        }
                    }
                }
                .id(date)
            }
            .listStyle(.grouped)
            loadingView
        }
        .refreshable {
            viewModel.swipeToRefresh()
        }
    }
    
    @ViewBuilder
    private var newSubmissionsBanner: some View {
        if viewModel.newSubmissionsCount > 0 {
            Button(action: {
                viewModel.newSubmissionsCount = 0
                viewModel.getSubmissionByType(field: "type", viewModel.submissionTypes)
            }) {
                Text("\(viewModel.newSubmissionsCount) new submissions added")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    private var filterView: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(SubmissionFilterType.allCases, id: \.self) { type in
                           Button(action: {
                               viewModel.getSubmissionByType(field: "type", type)
                           }) {
                               Text(type.displayName)
                                   .padding([.vertical, .horizontal], 8)
                                   .background(viewModel.submissionTypes == type ? Color.black : Color.gray.opacity(0.2))
                                   .foregroundColor(viewModel.submissionTypes == type ? Color.white : Color.primary)
                                   .fontWeight(viewModel.submissionTypes == type ? .bold : .semibold)
                                   .cornerRadius(6)
                           }
                           .tint(Color.black)
                       }
                }
                .padding(.leading, 8)
            }
            .scrollIndicators(.hidden)
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
    
    @ViewBuilder
    private func todayButtonView(scrollViewProxy: ScrollViewProxy) -> some View {
        if viewModel.isShowTodayButtonVisible {
            Button(action: {
                scrollViewProxy.scrollTo(viewModel.dateKey, anchor: .center)

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
    }
    
    @ViewBuilder
    private func sectionDateHeaderView(for date: Date) -> some View {
        let isToday = Calendar.current.isDate(date, inSameDayAs: viewModel.today)
        
        Text(viewModel.dateFormatted(date: date))
            .padding(.top, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isToday ? Color.gray.opacity(0.2) : Color.clear)
            .foregroundColor(.primary)
            .fontWeight(isToday ? .bold : .regular)
    }
    
    @ViewBuilder
    private func notificationIndicatorView(_ submission: MappedSubmission) -> some View {
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
    private func submissionRowView(_ submission: MappedSubmission) -> some View {
        SubmissionRowView(submission: submission, viewModel: viewModel)
            .swipeActions {
                if viewModel.currentUserRole == .admin {
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
                  
                        Button(role: .destructive) {
                            viewModel.markSubmissionAsCompleted(submission)
                        } label: {
                            Label("Complete", systemImage: "checkmark.seal")
                        }
                        .tint(.green)
                    
                } else if viewModel.currentUserRole == .user {
                    if submission.type != .completed  {
                        Button(role: .destructive) {
                            viewModel.markSubmissionAsCompleted(submission)
                        } label: {
                            Label("Complete", systemImage: "checkmark.seal")
                        }
                        .tint(.green)
                    }
                }
            }
            .swipeActions(edge: .leading) {
                if viewModel.currentUserRole == .admin {
                    if submission.type == .new {
                        Button(role: .cancel) {
                            viewModel.markSubmissionAsMessaged(submission)
                        } label: {
                            Label("Messaged", systemImage: "eye")
                        }
                    }
                    
                    if submission.type != .completed {
                        Button(role: .cancel) {
                            viewModel.markSubmissionAsDelegated(submission)
                        } label: {
                            Label("Delegate", systemImage: "figure.stand.line.dotted.figure.stand")
                        }
                    }
                }
            }
        
    }
}
