import SwiftUI
import FirebaseFirestore

enum SubmissionState {
    case deleted
    case completed
    case confirmed
    case orders
    case new
}
final class SubmissionsViewModel: ObservableObject {
    @Published var submissions: [MappedSubmission] = []
    @Published var title: String = ""
    @Published var isNewOrdersViewVisible: Bool = false
    @Published var newOrdersText: String = "0 New orders"
    @Published var groupedSubmissions: [Date : [MappedSubmission]] = [:]
    @Published var isLoading: Bool = false
    @Published var isLoaded: Bool = false
    private var db = Firestore.firestore()
    private let filloutService = FilloutService()
    private var pollingTimer: Timer?
    var newOrders:Int = 0
    
    func startPolling(state: SubmissionState) {
        stopPolling() 
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.fetchNewOrders(state: state)
        }
    }
    init() {
        getGroupedSubmissions()
    }
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    deinit {
        stopPolling()
    }

    func setPolling(state: SubmissionState) {
        if case .deleted = state {
            stopPolling()
            return
        } else if case .completed = state {
            stopPolling()
        } else {
            if pollingTimer == nil {
                startPolling(state: state)
            }
        }
    }
    
    func fetchSubmissions(state: SubmissionState, onAppear: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if onAppear {
                if !self.isLoaded {
                    self.isLoading = true
                }
            }
        }
        isNewOrdersViewVisible = false
        setPolling(state: state)
        setTitle(state: state)
        filloutService.fetchSubmissions { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let filloutSubmissions):
                    
                    self?.db.collection(ServerConfig.shared.collectionName).getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching submissions from Firestore: \(error)")
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            print("No documents found in Firestore")
                            return
                        }
                        
                        var firebaseSubmissions = documents.compactMap { queryDocumentSnapshot in
                            do {
                                return try queryDocumentSnapshot.data(as: FirebaseSubmission.self)
                            } catch {
                                print("Failed to decode document: \(error)")
                                return nil
                            }
                        }
                        
                        // loopFilloutSubmissionsIfNotExistAddtoExistingSubbmisions
                        for filloutSubmission in filloutSubmissions {
                            if let index = firebaseSubmissions.firstIndex(where: { $0.submissionId == filloutSubmission.submissionId }) {
                                firebaseSubmissions[index].lastUpdatedAt = filloutSubmission.lastUpdatedAt
                                firebaseSubmissions[index].submissionTime = filloutSubmission.submissionTime
                                firebaseSubmissions[index].questions = filloutSubmission.questions
                            } else {
                                
                                let sub = FirebaseSubmission(
                                    submissionId: filloutSubmission.submissionId,
                                    submissionTime: filloutSubmission.submissionTime,
                                    lastUpdatedAt: filloutSubmission.lastUpdatedAt,
                                    questions: filloutSubmission.questions
                                )
                                firebaseSubmissions.append(sub)
                            }
                        }

                        // Step 4: Save merged data back to Firestore
                        for firebaseSubmission in firebaseSubmissions {
                            if let id = firebaseSubmission.id {
                                try? self?.db.collection(ServerConfig.shared.collectionName).document(id).setData(from: firebaseSubmission)
                            } else {
                                let newDocRef = self?.db.collection(ServerConfig.shared.collectionName).document()
                                let mapped = MappedSubmission(
                                    collectionId: newDocRef?.documentID ?? "docID",
                                    submissionId: firebaseSubmission.submissionId,
                                    submissionTime: firebaseSubmission.submissionTime,
                                    lastUpdatedAt: firebaseSubmission.lastUpdatedAt,
                                    questions: firebaseSubmission.questions
                                )
                                try? newDocRef?.setData(from: mapped)
                            }
                        }
                        
                        // Update published submissions list
                        let list = firebaseSubmissions.map {
                            MappedSubmission(
                                collectionId: $0.id ?? "no-id",
                                submissionId: $0.submissionId,
                                submissionTime: $0.submissionTime,
                                lastUpdatedAt: $0.lastUpdatedAt,
                                questions: $0.questions,
                                isConfirmed: $0.isConfirmed,
                                isDeleted: $0.isDeleted,
                                isViewed: $0.isViewed,
                                isCompleted: $0.isCompleted
                            )
                        }
                        
                        var filteredList: [MappedSubmission]
                        switch state {
                        case .completed:
                            filteredList = list.filter { $0.isCompleted }
                        case .deleted:
                            filteredList = list.filter { $0.isDeleted }
                        case .confirmed:
                            filteredList = list.filter { $0.isConfirmed }
                        case .orders:
                            filteredList = list.filter { !$0.isDeleted && !$0.isCompleted }
                        case .new:
                            filteredList = list.filter { !$0.isDeleted && !$0.isCompleted && !$0.isConfirmed }
                        }
                        
                        self?.submissions = []
                        self?.submissions = filteredList
                        self?.getGroupedSubmissions()
                        
                        self?.isLoaded = true
                        self?.isLoading = false

                    }
                case .failure(let error):
                    print("Error fetching submissions from Fillout: \(error)")
                }
            }
        }
        newOrders = 0
        preloadImages()
    }
    
    func fetchNewOrders(state: SubmissionState) {
        setTitle(state: state)
        filloutService.fetchSubmissions { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let filloutSubmissions):
                    
                    self.db.collection(ServerConfig.shared.collectionName).getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching submissions from Firestore: \(error)")
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            print("No documents found in Firestore")
                            return
                        }

                        let firebaseSubmissions = documents.compactMap { queryDocumentSnapshot in
                            try? queryDocumentSnapshot.data(as: FirebaseSubmission.self)
                        }

                    
                        // loopFilloutSubmissionsIfNotExistAddtoExistingSubbmisions
                        self.newOrders = 0
                        for filloutSubmission in filloutSubmissions {
                            if let _ = firebaseSubmissions.firstIndex(where: { $0.submissionId == filloutSubmission.submissionId }) {
                               
                            } else {
                                self.newOrders = (self.newOrders) + 1
                            }
                        }
                        self.newOrdersText = "\(self.newOrders) New Orders"
                        
                        if self.newOrders > 0 {
                            self.isNewOrdersViewVisible = true
                        } else {
                            self.isNewOrdersViewVisible = false
                        }
                    }
                case .failure(let error):
                    print("Error fetching submissions from Fillout: \(error)")
                }
            }
        }
    }
    
    func setTitle(state: SubmissionState) {
        switch state {
        case .confirmed:
            title = "Confirmed orders"
        case .completed:
            title = "Completed orders"
        case .deleted:
            title = "Deleted orders"
        case .orders:
            title = "Orders"
        case .new:
            title = "New"
        }
    }
    func confirmSubmission(withId id: String) {
        guard let index = submissions.firstIndex(where: { $0.id == id }) else { return }
        
        DispatchQueue.main.async {
            self.submissions[index].isConfirmed = true
        }
        var submissionData = submissions[index]
        submissionData.isConfirmed = true
        
        fetchSubmission(by: submissionData.submissionId) { result in
            switch result {
            case .success(let submission):
                if let submission = submission {
                    try? self.db.collection(ServerConfig.shared.collectionName).document(submission.id ?? "").setData(from: submissionData)
                } else {
                    print("No submission found with the given ID.")
                }
            case .failure(let error):
                print("Error fetching submission: \(error.localizedDescription)")
            }
        }
        
    }
    
    func fetchSubmission(by submissionId: String, completion: @escaping (Result<FirebaseSubmission?, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection(ServerConfig.shared.collectionName)
            .whereField("submissionId", isEqualTo: submissionId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion(.success(nil))
                    return
                }
                
                do {
                    if let document = documents.first {
                        let submission = try document.data(as: FirebaseSubmission.self)
                        completion(.success(submission))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func getGroupedSubmissions(){
//        let sortedSubmissions = submissions.filter { !$0.isDeleted}
        let grouped = Dictionary(grouping: submissions) { submission in
            
            var date: Date?
            for question in submission.questions {
                if question.name == "Date of pickup" {
                    if case .string(let dateString) = question.value, let dateStr = dateString {
                        date = dateFormatter(stringDate: dateStr)
                        break
                    }
                }
            }
            return date ?? Date()
        }

        // Sort grouped submissions by date in descending order
        groupedSubmissions = grouped.sorted(by: { $0.key > $1.key }).reduce(into: [Date: [MappedSubmission]]()) {
            $0[$1.key] = $1.value
        }
    }
    
    func dateFormatter(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd"
        return  dateFormatter.date(from: stringDate) ?? Date()
    }
    
    func fetchSubmissionCustomerName(_ submission: MappedSubmission) -> String {
        for question in submission.questions {
            if question.name == "What's your instagram name?" {
                if case .string(let date) = question.value, let dates = date {
                    return dates
                }
            }
        }
        return "nil"
    }
    
    func fetchSubmissionCustomerPickupLocation(_ submission: MappedSubmission) -> String {
        for question in submission.questions {
            if question.name == "Select pick-up location" {
                if case .string(let date) = question.value, let dates = date {
                    return dates
                }
            }
        }
        return "nil"
    }
    
    func fetchSubmissionPickupDate(_ submission: MappedSubmission) -> String {
        for question in submission.questions {
            if question.name == "Date of pickup" {
                if case .string(let date) = question.value, let dates = date {
                    return dates
                }
            }
        }
        
        return "nil"
    }
    
    func getDaysAgo(submissionDate: Date?) -> String? {
        guard let submissionDate else { return nil }
        
        let currentDate = Date()
        
        // Calculate the difference in days between the current date and the submission date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: submissionDate, to: currentDate)
        guard let day = components.day else {
            return nil
        }
        
        if day == 0 {
            return "today"
        }
        return "-\(String(day)) days ago"
    }
    
    func fetchSubmissionCakeDescription(_ submission: MappedSubmission) -> String {
        var descriptionText = ""
        for question in submission.questions {
            if question.name == "Which shape would you like your cake?" || 
                question.name == "For how many people would you like the cake?" ||
                question.name == "Which flavour would you like the cake?" ||
                question.name == "Which flavour would you like the filling?"
            {
                if case .string(let value) = question.value, let stringValue = value {
                    descriptionText = descriptionText + " \(stringValue) -"
                }
            }
        }
        
        return descriptionText
    }
    
    func fetchSubmissionWithQuestion(_ submission: MappedSubmission, questionString: String) -> String? {
        for question in submission.questions {
            if question.name == questionString {
                if case .string(let value) = question.value, let stringValue = value {
                    return stringValue
                }
            }
        }
        
        return nil
    }
    
    func fetchSubmissionPickupDateAsDate(_ submission: MappedSubmission) -> Date {
        for question in submission.questions {
            if question.name == "Date of pickup" {
                if case .string(let date) = question.value, let dates = date {
                    return dateFormatter(stringDate: dates)
                }
            }
        }
        
        return Date()
    }
    
   
    
    func preloadImages() {
        for submission in submissions {
            for question in submission.questions {
                if let valueType = question.value {
                    switch valueType {
                    case .file(let files):
                        for file in files {
                            if let url = URL(string: file.url) {
                                preloadImage(from: url)
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func preloadImage(from url: URL) {
        let urlKey = NSURL(string: url.absoluteString)!
        // Skip if image already cached
        if ImageCache.shared.object(forKey: urlKey) != nil {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                // Cache the image
                ImageCache.shared.setObject(image, forKey: urlKey)
            }
        }.resume()
    }
    
    func markSubmissionAsViewed(_ submission: MappedSubmission) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
        submissions[index].isViewed = true

        let updatedSubmission = submissions[index]
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
        }
    }
    func markSubmissionAsDeleted(_ submission: MappedSubmission) {
        // Remove from the main submissions array
        guard let index = submissions.firstIndex(where: { $0.id == submission.id }) else {
            return
        }
        
        submissions[index].isDeleted = true

        let updatedSubmission = submissions[index]
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            for (date, var submissionsForDate) in self.groupedSubmissions {
                if let index = submissionsForDate.firstIndex(where: { $0.id == submission.id }) {
                    submissionsForDate.remove(at: index)
                    if submissionsForDate.isEmpty {
                        self.groupedSubmissions.removeValue(forKey: date)
                    } else {
                        self.groupedSubmissions[date] = submissionsForDate
                    }
                }
            }
            
            // Update the main submissions to trigger UI updates
            self.submissions = self.submissions.filter { !$0.isDeleted }
        }
    }
//    func markSubmissionAsDeleted(_ submission: MappedSubmission) {
//        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
//    
//        submissions[index].isDeleted = true
//        
//        // Update Firestore
//        let updatedSubmission = submissions[index]
//        do {
//            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
//        } catch let error {
//            print("Error updating submission: \(error.localizedDescription)")
//        }
//    }
    
    func markSubmissionAsCompleted(_ submission: MappedSubmission) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
    
        submissions[index].isCompleted = true
        
        // Update Firestore
        let updatedSubmission = submissions[index]
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            for (date, var submissionsForDate) in self.groupedSubmissions {
                if let index = submissionsForDate.firstIndex(where: { $0.id == submission.id }) {
                    submissionsForDate.remove(at: index)
                    if submissionsForDate.isEmpty {
                        self.groupedSubmissions.removeValue(forKey: date)
                    } else {
                        self.groupedSubmissions[date] = submissionsForDate
                    }
                }
            }
            
            // Update the main submissions to trigger UI updates
            self.submissions = self.submissions.filter { !$0.isDeleted }
        }
        
    }
}
