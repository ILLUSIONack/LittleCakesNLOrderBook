import SwiftUI
import FirebaseFirestore

final class SubmissionsViewModel: ObservableObject {
    @Published var submissions: [MappedSubmission] = []
    private var db = Firestore.firestore()
    private let filloutService = FilloutService()

    func fetchSubmissions() {
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

                        var existingSubmissions = documents.compactMap { queryDocumentSnapshot in
                            try? queryDocumentSnapshot.data(as: FirebaseSubmission.self)
                        }

                    
                        // loopFilloutSubmissionsIfNotExistAddtoExistingSubbmisions
                        for filloutSubmission in filloutSubmissions {
                            if let index = existingSubmissions.firstIndex(where: { $0.submissionId == filloutSubmission.submissionId }) {
                                existingSubmissions[index].lastUpdatedAt = filloutSubmission.lastUpdatedAt
                                existingSubmissions[index].submissionTime = filloutSubmission.submissionTime
                                existingSubmissions[index].questions = filloutSubmission.questions
                            } else {
                                
                                let sub = FirebaseSubmission(submissionId: filloutSubmission.submissionId, submissionTime: filloutSubmission.submissionTime, lastUpdatedAt: filloutSubmission.lastUpdatedAt, questions: filloutSubmission.questions)
                                existingSubmissions.append(sub)
                            }
                        }

                        // Step 4: Save merged data back to Firestore
                        for existingSubmission in existingSubmissions {
                            if let id = existingSubmission.id {
                                try? self?.db.collection(ServerConfig.shared.collectionName).document(id).setData(from: existingSubmission)
                            } else {
                                let newDocRef = self?.db.collection(ServerConfig.shared.collectionName).document()
                                try? newDocRef?.setData(from: existingSubmission)
                            }
                        }

                        // Update published submissions list
                        let list = existingSubmissions.map { MappedSubmission(submissionId: $0.submissionId, submissionTime: $0.submissionTime, lastUpdatedAt: $0.lastUpdatedAt, questions: $0.questions, isConfirmed: $0.isConfirmed)}
                        DispatchQueue.main.async {
                            self?.submissions = list
                        }
                    }
                case .failure(let error):
                    print("Error fetching submissions from Fillout: \(error)")
                }
            }
        }
        preloadImages()
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

    func groupedSubmissions() -> [Date: [MappedSubmission]] {
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
        return grouped.sorted(by: { $0.key > $1.key }).reduce(into: [Date: [MappedSubmission]]()) {
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
}
