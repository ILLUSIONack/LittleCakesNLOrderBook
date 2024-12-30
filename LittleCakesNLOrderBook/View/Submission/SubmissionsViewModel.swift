import SwiftUI
import FirebaseFirestore

final class SubmissionsViewModel: ObservableObject {
    @Published var submissions: [MappedSubmission] = []
    @Published var groupedSubmissions: [Date : [MappedSubmission]] = [:]
    @Published var filteredSubmissions: [MappedSubmission] = []
    @Published var isLoading: Bool = false
    @Published var isShowTodayButtonVisible: Bool = false
    @Published var dateKey: Dictionary<Date, [MappedSubmission]>.Keys.Element?
    @Published var submissionType: SubmissionType = .new
    @Published var title: String = ""

    private var db: Firestore
    private let filloutService: FilloutService

    init(firestoreManager: FirestoreManager, filloutService: FilloutService) {
        self.db = firestoreManager.db
        self.filloutService = filloutService
        fetchSubmissions()
    }
    
    func fetchSubmissions() {
        var currentOffset = 0
        let limit = 50
        
        func fetchBatch() {
            filloutService.fetchSubmissions(limit: limit, offset: currentOffset) { [weak self] result in
                guard let self else { return }
                
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
                                    questions: questions,
                                    type: .new,
                                    state: .unviewed
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
                                type: $0.type,
                                state: $0.state
                            )
                        }
                        
                        list.append(contentsOf: filteredList)
                        print(self.submissions.count)
                        
                        if filloutSubmissions.count == limit {
                            currentOffset += limit
                            fetchBatch()
                        } else {
                            print("Finished count")

                        }
                    }
                case .failure(let error):
                    print("Error fetching submissions from Fillout: \(error)")
                }
            }
        }
        
        fetchBatch()
    }
    
    func getSubmissionByType(field: String, value: String) {
        self.isLoading = true

        fetchAndMapSubmissions(field: field, value: value) { mappedSubmissions, error in
            if let error = error {
                print("Failed to fetch submissions: \(error.localizedDescription)")
                return
            }
            
            if let mappedSubmissions = mappedSubmissions {
                print("Fetched \(mappedSubmissions.count) submissions of type \(field)")
                
                self.submissions = mappedSubmissions
                self.getGroupedSubmissions()
                self.isLoading = false
            }
        }
    }
    
    func fetchAndMapSubmissions(
        field: String,
        value: String,
        completion: @escaping ([MappedSubmission]?, Error?) -> Void
    ) {
        let submissionsCollection = db.collection("submissionsReleaseBackup")
        
        submissionsCollection.whereField(field, isEqualTo: value).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching submissions by \(field): \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No submissions found for \(field): \(value)")
                completion([], nil)
                return
            }
            
            do {
                // Decode the documents into `FirebaseSubmission` objects
                let firebaseSubmissions = try documents.map { document in
                    try document.data(as: FirebaseSubmission.self)
                }
                
                // Map FirebaseSubmission to MappedSubmission (without legacy fields)
                let mappedSubmissions = firebaseSubmissions.map { submission in
                    MappedSubmission(
                        collectionId: submission.id ?? "",
                        submissionId: submission.submissionId,
                        submissionTime: submission.submissionTime,
                        lastUpdatedAt: submission.lastUpdatedAt,
                        questions: submission.questions,
                        type: submission.type,
                        state: submission.state
                    )
                }
                
                completion(mappedSubmissions, nil)
            } catch {
                print("Error decoding or mapping submissions: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            setNavigationTitle()
            var subs = submissions
            if !filteredSubmissions.isEmpty {
                subs = filteredSubmissions
            }
            let grouped = Dictionary(grouping: subs) { submission in
                
                var date: Date?
                for question in submission.questions {
                    if question.name == Questions.dateOfPickup.rawValue {
                        if case .string(let dateString) = question.value, let dateStr = dateString {
                            date = self.dateFormatter(stringDate: dateStr)
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
    }
    
    func setNavigationTitle() {
        switch submissionType {
        case .completed: title = "Completed"
        case .confirmed: title = "Confirmed"
        case .deleted: title = "Deleted"
        case .new: title = "New"
        }
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
    
    func dateFormatterProper(stringDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = inputFormatter.date(from: stringDate) {
            return outputFormatter.string(from: date)
        } else {
            return outputFormatter.string(from: Date())
        }
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
    
    func getConfirmationMessageCopy(_ submission: MappedSubmission) -> String {
        var dateOfPickup = ""
        var order = ""
        var flavour = ""
        var filling = ""
        var people = ""
        var extras = ""
        var cakeTextAndColor = ""
        var cakeTextType = ""
        var cupcakesAmount = ""

        for question in submission.questions {
            if question.name == Questions.dateOfPickup.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    dateOfPickup = stringValue
                }
            }
            if question.name == Questions.cakeFlavour.rawValue ||
                question.name == Questions.cakeFlavour1to4.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    flavour = stringValue
                }
            }
            
            if question.name == Questions.cakeFilling.rawValue ||
                question.name == Questions.cakeFilling1to4.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    filling = stringValue
                }
            }
            
            if question.name == Questions.order.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    order = stringValue
                }
            }
            if question.name == Questions.order.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    order = stringValue
                }
            }
            
            if question.name == Questions.orderSize.rawValue ||
                question.name == Questions.orderSize1.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    people = stringValue
                }
            }
            
            if question.name == Questions.extras.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    extras = stringValue
                }
            }
            
            if question.name == Questions.cakeTextAndColor.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    cakeTextAndColor = stringValue
                }
            }
            
            if question.name == Questions.cakeTextType.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    cakeTextType = stringValue
                }
            }
            
            if question.name == Questions.cupcakesAmount.rawValue ||
                question.name == Questions.cupcakesAmount1.rawValue
            {
                if case .string(let value) = question.value, let stringValue = value {
                    cupcakesAmount = stringValue
                }
            }
        }
        
        if cupcakesAmount.count > 0 {
            return "Goededag dankjewel voor het invullen van de bestelformulier, je gekozen bestelling is mogelijk op \(dateFormatterProper(stringDate: dateOfPickup)). Hieronder vind je een samenvatting: \n - \(order) \n - \(cupcakesAmount) \n - Extra: \(extras) \n \n Totaal prijs wordt: \n Aanbetaling om te bevestigen wordt:"
        } else {
            return "Goededag dankjewel voor het invullen van de bestelformulier, je gekozen bestelling is mogelijk op \(dateFormatterProper(stringDate: dateOfPickup)). Hieronder vind je een samenvatting: \n - \(flavour) \n - \(order) \n - \(people) \n - \(filling)\n - \(cakeTextAndColor) \n - \(cakeTextType) \n - Extra: \(extras) \n \n Totaal prijs wordt: \n Aanbetaling om te bevestigen wordt:"
        }
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
    
    func getCachedImage(for file: File) -> UIImage? {
        if let cachedImage = ImageCache.shared.object(forKey: NSURL(string: file.url)! as NSURL) {
             return cachedImage
        } else if let url = URL(string: file.url) {
            let urlKey = NSURL(string: file.url)!

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
        }
        return nil
    }
    
    func updateSubmission(_ submission: MappedSubmission, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }

        let editedSubmission = MappedSubmission(
            collectionId: submission.collectionId,
            submissionId: submission.submissionId,
            submissionTime: submission.submissionTime,
            lastUpdatedAt: submission.lastUpdatedAt,
            questions: submission.questions,
            type: submission.type,
            state: submission.state
        )
        
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: editedSubmission)
            completion(.success(()))
            
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Mark submissions as Viewed/Confirmed/Deleted/Completed
    
    func confirmSubmission(withId id: String) {
        guard let index = submissions.firstIndex(where: { $0.id == id }) else { return }
        
        DispatchQueue.main.async {
            self.submissions[index].type = .confirmed
        }
        var submissionData = submissions[index]
        submissionData.type = .confirmed
        
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
    
    func markSubmissionAsViewed(_ submission: MappedSubmission) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
        if submissions[index].state != .messaged {
            submissions[index].state = .viewed
        }

        let updatedSubmission = submissions[index]
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
        }
    }
    
    func markSubmissionAsDeleted(_ submission: MappedSubmission, type: SubmissionType) {
        guard let index = submissions.firstIndex(where: { $0.id == submission.id }) else {
            return
        }
        
        submissions[index].type = type

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
        
        // Update the submission's type to .completed
        submissions[index].type = .completed
        
        let updatedSubmission = submissions[index]
        do {
            // Update the Firestore database with the new state
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
        }
        
        // Perform UI update on the main thread
        DispatchQueue.main.async {
            withAnimation {
                for (date, var submissionsForDate) in self.groupedSubmissions {
                    if let index = submissionsForDate.firstIndex(where: { $0.id == submission.id }) {
                        // Remove the submission and update the grouped submissions
                        submissionsForDate.remove(at: index)
                        if submissionsForDate.isEmpty {
                            // Remove the empty date group if no submissions remain
                            self.groupedSubmissions.removeValue(forKey: date)
                        } else {
                            // Otherwise, update the date group with the remaining submissions
                            self.groupedSubmissions[date] = submissionsForDate
                        }
                    }
                }
            }
        }
    }
    
    func markSubmissionAsMessaged(_ submission: MappedSubmission) {
        guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
    
        submissions[index].state = .messaged
        
        let updatedSubmission = submissions[index]
        do {
            try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
            DispatchQueue.main.async {
                       withAnimation {
                           self.getGroupedSubmissions()
                       }
                   }
        } catch let error {
            print("Error updating submission: \(error.localizedDescription)")
        }
    }
}