import SwiftUI
import FirebaseFirestore
import FirebaseFunctions


final class SubmissionsViewModel: ObservableObject {
  @Published var groupedSubmissions: [Date : [MappedSubmission]] = [:]
  @Published var filteredSubmissions: [MappedSubmission] = []
  @Published var isLoading: Bool = true
  @Published var isShowTodayButtonVisible: Bool = false
  @Published var dateKey: Dictionary<Date, [MappedSubmission]>.Keys.Element?
  @Published var submissionTypes: SubmissionFilterType = .newAndConfirmed
  @Published var title: String = ""
  @Published var newSubmissionsCount = 0
  @Published var isFilterViewVisible: Bool = true
  @Published var searchText: String = ""
  @Published var isSearchBarVisible: Bool = false
  @FocusState var isSearchBarFocused: Bool
  let today = Date()

  private var submissions: [MappedSubmission] = []
  private var db: Firestore
  private let authenticationManager: AuthenticationService
  private let filloutService: FilloutService

  private var listener: ListenerRegistration?
  private var seenDocumentIDs: Set<String> = []
  private var isFirstSnapshot = true
  @Published var currentUserRole: UserRole = .user
  var isDelegated: Bool

  init(
    firestoreManager: FirestoreManager,
    authenticationManager: AuthenticationService,
    filloutService: FilloutService,
    isDelegated: Bool = false
  ) {
    self.db = firestoreManager.db
    self.authenticationManager = authenticationManager
    self.filloutService = filloutService
    self.isDelegated = isDelegated

    if let currentUser = authenticationManager.currentUser {
      currentUserRole = currentUser.role
    }

    if currentUserRole == .admin {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.startListeningForNewSubmissions()
      }
    }

    if currentUserRole == .admin && isDelegated {
      isFilterViewVisible = false
      fetchAndMapDelegatedSubmissions()
    } else if currentUserRole == .admin {
      getSubmissionByType(field: "type", .newAndConfirmed)
    } else {
      isFilterViewVisible = false
      fetchAndMapDelegatedSubmissions()
    }
  }

  func swipeToRefresh() {
    if currentUserRole == .admin && isDelegated {
      isFilterViewVisible = false
      fetchAndMapDelegatedSubmissions()
    } else if currentUserRole == .admin {
      getSubmissionByType(field: "type", .newAndConfirmed)
    } else {
      isFilterViewVisible = false
      fetchAndMapDelegatedSubmissions()
    }
  }

  func getSubmissionByType(field: String, _ submissionFilterType: SubmissionFilterType) {
    generateFeedback(style: .medium)
    isLoading = true
    submissionTypes = submissionFilterType

    let stringTypes = submissionFilterType.submissionTypes.map { $0.rawValue }

    fetchAndMapSubmissions(field: field, values: stringTypes) { mappedSubmissions, error in
      if let error = error {
        print("Failed to fetch submissions: \(error.localizedDescription)")
        return
      }

      if let mappedSubmissions = mappedSubmissions {
        print("Fetched \(mappedSubmissions.count) submissions of type \(field)")

        DispatchQueue.main.async {
          self.submissions = mappedSubmissions
          self.getGroupedSubmissions()
        }
      }
    }
  }

  func fetchAndMapSubmissions(
    field: String,
    values: [String],
    completion: @escaping ([MappedSubmission]?, Error?) -> Void
  ) {
    db.collection(ServerConfig.shared.collectionName).whereField(field, in: values).getDocuments { snapshot, error in
      if let error = error {
        print("Error fetching submissions by \(field): \(error.localizedDescription)")
        completion(nil, error)
        return
      }

      guard let documents = snapshot?.documents else {
        print("No submissions found for \(field): \(values)")
        completion([], nil)
        return
      }

      do {
        let firebaseSubmissions = try documents.map { document in
          try document.data(as: FirebaseSubmission.self)
        }

        let mappedSubmissions = firebaseSubmissions.map { submission in
          MappedSubmission(
            collectionId: submission.id ?? "",
            submissionId: submission.submissionId,
            submissionTime: submission.submissionTime,
            lastUpdatedAt: submission.lastUpdatedAt,
            questions: submission.questions,
            type: submission.type,
            state: submission.state,
            isDelegated: submission.isDelegated
          )
        }

        completion(mappedSubmissions, nil)
      } catch {
        print("Error decoding or mapping submissions: \(error.localizedDescription)")
        completion(nil, error)
      }
    }
  }

  func fetchAndMapDelegatedSubmissions() {
    db.collection(ServerConfig.shared.collectionName).whereField("isDelegated", isEqualTo: true).getDocuments { snapshot, error in
      if let error = error {
        print("Error fetching submissions by isDelegated: \(error.localizedDescription)")
        return
      }

      guard let documents = snapshot?.documents else {
        print("No submissions found for isDelegated:")
        return
      }

      do {
        let firebaseSubmissions = try documents.map { document in
          try document.data(as: FirebaseSubmission.self)
        }

        let mappedSubmissions = firebaseSubmissions.map { submission in
          MappedSubmission(
            collectionId: submission.id ?? "",
            submissionId: submission.submissionId,
            submissionTime: submission.submissionTime,
            lastUpdatedAt: submission.lastUpdatedAt,
            questions: submission.questions,
            type: submission.type,
            state: submission.state,
            isDelegated: submission.isDelegated
          )
        }

        DispatchQueue.main.async {
          self.submissions = mappedSubmissions
          self.getGroupedSubmissions()
        }
      } catch {
        print("Error decoding or mapping submissions: \(error.localizedDescription)")
      }
    }
  }

  func filterSubmissions(by name: String) {
    filteredSubmissions.removeAll()
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

      self.isLoading = false
      setupShowTodayButton()
    }
  }

  func setNavigationTitle() {
    switch submissionTypes {
    case .newAndConfirmed: title = "All"
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

  func getConfirmationMessageCopy(_ submission: MappedSubmission, totalPrice: Double, isEnglish: Bool) -> String {
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

    if isEnglish {
      if cupcakesAmount.count > 0 {
        return "Good day, thank you for filling out the order form. Your selected order is possible on \(dateFormatterProper(stringDate: dateOfPickup)). Below you’ll find a summary: \n - \(order) \n - \(cupcakesAmount) \n - Extra: \(extras) \n \n Total price will be: \(totalPrice) \n Down payment to confirm will be:"
      } else {
        return "Good day, thank you for filling out the order form. Your selected order is possible on \(dateFormatterProper(stringDate: dateOfPickup)). Below you’ll find a summary: \n - \(flavour) \n - \(order) \n - \(people) \n - \(filling)\n - \(cakeTextAndColor) \n - \(cakeTextType) \n - Extra: \(extras) \n \n Total price will be: €\(totalPrice) \n Down payment to confirm will be:"
      }
    } else {
      if cupcakesAmount.count > 0 {
        return "Goededag dankjewel voor het invullen van de bestelformulier, je gekozen bestelling is mogelijk op \(dateFormatterProper(stringDate: dateOfPickup)). Hieronder vind je een samenvatting: \n - \(order) \n - \(cupcakesAmount) \n - Extra: \(extras) \n \n Totaal prijs wordt: \(totalPrice) \n Aanbetaling om te bevestigen wordt:"
      } else {
        return "Goededag dankjewel voor het invullen van de bestelformulier, je gekozen bestelling is mogelijk op \(dateFormatterProper(stringDate: dateOfPickup)). Hieronder vind je een samenvatting: \n - \(flavour) \n - \(order) \n - \(people) \n - \(filling)\n - \(cakeTextAndColor) \n - \(cakeTextType) \n - Extra: \(extras) \n \n Totaal prijs wordt: €\(totalPrice) \n Aanbetaling om te bevestigen wordt:"
      }
    }
  }

  func getSubmissionShape(_ submission: MappedSubmission) -> CakeShape {
    var shape = ""

    for question in submission.questions {
      if question.name == Questions.orderShape.rawValue {
        if case .string(let value) = question.value, let stringValue = value {
          shape = stringValue
        }
      }
    }

    return CakeShape(rawValue: shape) ?? .round
  }

  func getSubmissionSize(_ submission: MappedSubmission) -> CakeSize {
    var size = ""
    for question in submission.questions {
      if question.name == Questions.orderSize.rawValue ||
          question.name == Questions.orderSize1.rawValue
      {
        if case .string(let value) = question.value, let stringValue = value {
          size = stringValue.trimmingCharacters(in: .whitespaces)
        }
      }
    }

    return CakeSize(rawValue: size) ?? .oneToFour
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

  func confirmSubmission(withId submission: MappedSubmission, type: SubmissionType) {
    guard let index = submissions.firstIndex(where: { $0.id == submission.id }) else {
      return
    }

    submissions[index].type = type
    submissions[index].state = .viewed

    let updatedSubmission = submissions[index]
    do {
      try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
    } catch let error {
      print("Error updating submission: \(error.localizedDescription)")
    }
  }

  func markSubmissionAsViewed(_ submission: MappedSubmission) {
    guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }
    if submissions[index].state != .messaged {
      submissions[index].state = .viewed
      let updatedSubmission = submissions[index]
      getGroupedSubmissions()
      do {
        try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
      } catch let error {
        print("Error updating submission: \(error.localizedDescription)")
      }
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

    if submissions[index].type == .completed {
      submissions[index].type = .confirmed
    } else {
      submissions[index].type = .completed
    }

    let updatedSubmission = submissions[index]
    do {
      // Update the Firestore database with the new state
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

  func markSubmissionAsMessaged(_ submission: MappedSubmission) {
    guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }

    if submissions[index].state == .messaged {
      submissions[index].state = .viewed
    } else {
      submissions[index].state = .messaged
    }


    let updatedSubmission = submissions[index]
    self.getGroupedSubmissions()

    do {
      try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
    } catch let error {
      print("Error updating submission: \(error.localizedDescription)")
    }
  }

  func markSubmissionAsDelegated(_ submission: MappedSubmission) {
    guard let index = submissions.firstIndex(where: { $0.submissionId == submission.submissionId }) else { return }

    submissions[index].isDelegated = !(submissions[index].isDelegated ?? false)

    let updatedSubmission = submissions[index]
    self.getGroupedSubmissions()

    do {
      try db.collection(ServerConfig.shared.collectionName).document(submissions[index].collectionId).setData(from: updatedSubmission)
    } catch let error {
      print("Error updating submission: \(error.localizedDescription)")
    }
  }

  func generateFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    feedbackGenerator.impactOccurred()
  }

  func dateFormatted(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
  }

  // MARK: - Authentication
  func signOut() {
    authenticationManager.signOut { error in
      if let error {
        print(error.localizedDescription)
      } else {
        print("Signed out")
      }
    }
  }

  func startListeningForNewSubmissions() {
    let submissionsCollection = db.collection(ServerConfig.shared.collectionName)

    listener = submissionsCollection.whereField("type", isEqualTo: "new")
      .addSnapshotListener { [weak self] snapshot, error in
        guard let self else { return }
        if let error = error {
          print("Error listening for submissions: \(error.localizedDescription)")
          return
        }

        guard let snapshot = snapshot else { return }

        // If it's the first snapshot, initialize the seen IDs and skip processing
        if isFirstSnapshot {
          seenDocumentIDs = Set(snapshot.documents.map { $0.documentID })
          isFirstSnapshot = false
          return
        }

        // Extract the document IDs from the current snapshot
        let currentDocumentIDs = Set(snapshot.documents.map { $0.documentID })

        // Find new IDs by subtracting the already seen IDs
        let newDocumentIDs = currentDocumentIDs.subtracting(seenDocumentIDs)

        // Update the seen IDs set
        seenDocumentIDs.formUnion(newDocumentIDs)

        // Increment the count for new submissions
        newSubmissionsCount += newDocumentIDs.count

        // Debugging output
        print("Newly added documents count: \(newDocumentIDs.count)")
        print("Total new submissions: \(newSubmissionsCount)")
      }
  }

  func stopListening() {
    listener?.remove()
    listener = nil
  }
}
