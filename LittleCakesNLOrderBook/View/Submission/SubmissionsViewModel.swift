import SwiftUI
import FirebaseFirestore

enum SubmissionState {
    case deleted
    case completed
    case confirmed
    case orders
}

final class SubmissionsViewModel: ObservableObject {
    @Published var submissions: [MappedSubmission] = []
    @Published var title: String = ""
    @Published var isNewOrdersViewVisible: Bool = false
    @Published var newOrdersText: String = "0 New orders"
    @Published var groupedSubmissions: [Date : [MappedSubmission]] = [:]
    @Published var filteredSubmissions: [MappedSubmission] = []
    @Published var isLoading: Bool = false
    @Published var isLoaded: Bool = false
    @Published var isShowTodayButtonVisible: Bool = false
    @Published var dateKey: Dictionary<Date, [MappedSubmission]>.Keys.Element?

    private var isPreloadedImages: Bool = false
    private var isNewFilteredActive: Bool = false
    private var submissionState: SubmissionState?
    private var db: Firestore
    private let filloutService = FilloutService()
    private var pollingTimer: Timer?
    var newOrders:Int = 0
    private var allOrders: [MappedSubmission] = []
    
    func startPolling(state: SubmissionState) {
        stopPolling() 
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
//            self?.fetchNewOrders(state: state)
        }
    }
    
    init(firestoreManager: FirestoreManager) {
        self.db = firestoreManager.db

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
        submissionState = state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if onAppear {
                if !self.isLoaded {
                    self.isLoading = true
                }
            }
        }
        isNewOrdersViewVisible = false
        setTitle(state: state)

        var currentOffset = 0
        let limit = 50 // Define your desired limit

        func fetchBatch() {
            filloutService.fetchSubmissions(limit: limit, offset: currentOffset) { [weak self] result in
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
                                do {
                                    return try queryDocumentSnapshot.data(as: FirebaseSubmission.self)
                                } catch {
                                    print("Failed to decode document: \(error)")
                                    return nil
                                }
                            }

                            var filteredList: [MappedSubmission] = []
                            let batch = self.db.batch()

                            // Iterate over filloutSubmissions
                            for filloutSubmission in filloutSubmissions {
                                let isExistsFirebaseSubmission = firebaseSubmissions.contains {
                                    $0.submissionId == filloutSubmission.submissionId
                                }

                                if !isExistsFirebaseSubmission {
                                    let newDocRef = self.db.collection(ServerConfig.shared.collectionName).document()

                                    var questions = filloutSubmission.questions
                                    questions.append(SubmissionQuestion(id: String(filloutSubmission.questions.count), name: "Total amount €", type: "ShortAnswer", value: ValueType(string: " ")))
                                    questions.append(SubmissionQuestion(id: String(filloutSubmission.questions.count + 1), name: "Remaining amount €", type: "ShortAnswer", value: ValueType(string: " ")))
                                    questions.append(SubmissionQuestion(id: String(filloutSubmission.questions.count + 2), name: "Notitie", type: "ShortAnswer", value: ValueType(string: " ")))

                                    let mappedSubmission = MappedSubmission(
                                        collectionId: newDocRef.documentID,
                                        submissionId: filloutSubmission.submissionId,
                                        submissionTime: filloutSubmission.submissionTime,
                                        lastUpdatedAt: filloutSubmission.lastUpdatedAt,
                                        questions: questions
                                    )

                                    filteredList.append(mappedSubmission)

                                    do {
                                        try batch.setData(from: mappedSubmission, forDocument: newDocRef)
                                    } catch {
                                        print("Error encoding mapped submission: \(error)")
                                    }
                                }
                            }

                            batch.commit { error in
                                if let error = error {
                                    print("Error committing batch write: \(error)")
                                } else {
                                    print("Batch write successfully committed.")
                                }
                            }

                            var list = firebaseSubmissions.map {
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

                            list.append(contentsOf: filteredList)

                            switch state {
                            case .completed:
                                filteredList = list.filter { $0.isCompleted }
                            case .deleted:
                                filteredList = list.filter { $0.isDeleted }
                            case .confirmed:
                                filteredList = list.filter { $0.isConfirmed }
                            case .orders:
                                if self.isNewFilteredActive {
                                    filteredList = list.filter { !$0.isConfirmed && !$0.isCompleted && !$0.isDeleted }
                                } else {
                                    filteredList = list.filter { !$0.isDeleted && !$0.isCompleted }
                                    self.allOrders = list.filter { !$0.isDeleted && !$0.isCompleted }
                                    
                                }
                            }

                            self.submissions = filteredList
                            self.getGroupedSubmissions()
                            print(self.submissions.count)

                            self.isLoaded = true
                            self.isLoading = false

                            // Check if more submissions were fetched and fetch the next batch if necessary
                            if filloutSubmissions.count == limit {
                                currentOffset += limit
                                fetchBatch()
                            } else {
                                self.preloadImages()
                            }
                        }
                    case .failure(let error):
                        print("Error fetching submissions from Fillout: \(error)")
                        self.isLoading = false
                    }
                }
            }
        }

        // Start fetching the first batch
        fetchBatch()
//        self.preloadImages()
        newOrders = 0
    }
    
    func filterNewButtonPressed() {
        isNewFilteredActive.toggle()
        print(isNewFilteredActive)
        if isNewFilteredActive == true {
            let filteredList = submissions.filter { !$0.isConfirmed && !$0.isCompleted && !$0.isDeleted }
            self.submissions = filteredList
            setTitle(state: .orders)
            getGroupedSubmissions()

        } else {
            self.submissions = allOrders
            setTitle(state: .orders)
            getGroupedSubmissions()
        }
//        fetchSubmissions(state: submissionState ?? .orders, onAppear: false)
    }
    
    func filterSubmissions(by name: String) {
        if name.isEmpty {
            filteredSubmissions.removeAll()
            getGroupedSubmissions()
        } else {
            filteredSubmissions = submissions.filter { submission in
                submission.questions.contains { question in
                    if question.name == Questions.name.rawValue {
                        return question.value?.stringValue?.lowercased().contains(name.lowercased()) ?? false
                    }
                    return false
                }
            }
        }

        getGroupedSubmissions()
    }
    
//    func fetchNewOrders(state: SubmissionState) {
//        setTitle(state: state)
//        filloutService.fetchSubmissions { [weak self] result in
//            guard let self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let filloutSubmissions):
//                    
//                    self.db.collection(ServerConfig.shared.collectionName).getDocuments { snapshot, error in
//                        if let error = error {
//                            print("Error fetching submissions from Firestore: \(error)")
//                            return
//                        }
//
//                        guard let documents = snapshot?.documents else {
//                            print("No documents found in Firestore")
//                            return
//                        }
//
//                        let firebaseSubmissions = documents.compactMap { queryDocumentSnapshot in
//                            try? queryDocumentSnapshot.data(as: FirebaseSubmission.self)
//                        }
//
//                        // loopFilloutSubmissionsIfNotExistAddtoExistingSubbmisions
//                        self.newOrders = 0
//                        for filloutSubmission in filloutSubmissions {
//                            if let _ = firebaseSubmissions.firstIndex(where: { $0.submissionId == filloutSubmission.submissionId }) {
//                               
//                            } else {
//                                self.newOrders = (self.newOrders) + 1
//                            }
//                        }
//                        self.newOrdersText = "\(self.newOrders) New Orders"
//                        
//                        if self.newOrders > 0 {
//                            self.isNewOrdersViewVisible = true
//                        } else {
//                            self.isNewOrdersViewVisible = false
//                        }
//                    }
//                case .failure(let error):
//                    print("Error fetching submissions from Fillout: \(error)")
//                }
//            }
//        }
//    }
    
    func setTitle(state: SubmissionState) {
        switch state {
        case .confirmed:
            title = "Confirmed"
        case .completed:
            title = "Completed"
        case .deleted:
            title = "Deleted"
        case .orders:
            title = isNewFilteredActive ? "New" :" Orders"
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
        var subs = submissions
        if !filteredSubmissions.isEmpty {
            subs = filteredSubmissions
        }
        let grouped = Dictionary(grouping: subs) { submission in
            
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

        groupedSubmissions = grouped.sorted(by: { $0.key > $1.key }).reduce(into: [Date: [MappedSubmission]]()) {
            $0[$1.key] = $1.value
        }
        
        setupShowTodayButton()
    }
    
    func setupShowTodayButton() {
        if let date = groupedSubmissions.keys.first(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) {
            isShowTodayButtonVisible = true
            dateKey = date
        } else {
            isShowTodayButtonVisible = false
        }
    }
    
    func dateFormatter(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd"
        return  dateFormatter.date(from: stringDate) ?? Date()
    }
    
    func getDaysAgo(submissionDate: Date?) -> String? {
        guard let submissionDate else { return nil }
        
        let currentDate = Date()
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
            if question.name == Questions.orderShape.rawValue ||
                question.name == Questions.orderSize.rawValue ||
                question.name == Questions.cakeFlavour.rawValue ||
                question.name == Questions.cakeFilling.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    descriptionText = descriptionText + " \(stringValue) -"
                }
            }
        }
        
        return descriptionText
    }
    
    func fetchSubmissionWithQuestion(_ submission: MappedSubmission, _ question: Questions) -> String? {
        for quest in submission.questions {
            if quest.name == question.rawValue {
                if case .string(let value) = quest.value, let stringValue = value {
                    return stringValue
                }
            }
        }
        
        return nil
    }
    
    func fetchSubmissionPickupDateAsDate(_ submission: MappedSubmission) -> Date {
        for question in submission.questions {
            if question.name == Questions.dateOfPickup.rawValue{
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
        if ImageCache.shared.object(forKey: urlKey) != nil {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.global(qos: .userInitiated).async {
                    // Resize the image in the background thread
                    let resizedImage = image.resizedMaintainingAspectRatio(targetSize: CGSize(width: 1000, height: 1000))
                    
                    // Cache and update UI on the main thread
                    DispatchQueue.main.async {
                        ImageCache.shared.setObject(resizedImage, forKey: urlKey)
                    }
                }
            }
        }.resume()
//        isPreloadedImages = true
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
    func markSubmissionAsDeleted(_ submission: MappedSubmission, state: Bool) {
        // Remove from the main submissions array
        guard let index = submissions.firstIndex(where: { $0.id == submission.id }) else {
            return
        }
        
        submissions[index].isDeleted = state
        submissions[index].isCompleted = false
        submissions[index].isConfirmed = false

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
        }
    }
    
    func markSubmissionAsCompleted(_ submission: MappedSubmission) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
    
        submissions[index].isCompleted = true
        submissions[index].isConfirmed = false
        submissions[index].isDeleted = false
        
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
        }
    }
    
    func updateSubmission(_ submission: MappedSubmission, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }

        let editedSubmission = MappedSubmission(
            collectionId: submission.collectionId,
            submissionId: submission.submissionId,
            submissionTime: submission.submissionTime,
            lastUpdatedAt: submission.lastUpdatedAt,
            questions: submission.questions,
            isConfirmed: submission.isConfirmed,
            isDeleted: submission.isDeleted,
            isViewed: true,
            isCompleted: submission.isCompleted
        )
        
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: editedSubmission)
            completion(.success(()))
            
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
