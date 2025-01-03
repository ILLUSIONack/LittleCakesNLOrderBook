import Foundation
import FirebaseFirestore

enum Questions: String {
    case name = "What's your instagram name?"
    case pickUpType = "How do you want to receive the cake?"
    case userAddress = "What's your address?"
    case pickupLocation = "Select pick-up location"
    case dateOfPickup = "Date of pickup"
    case order = "What would you like to order?"
    case orderShape = "Which shape would you like your cake?"
    
    case orderSize = "For how many people would you like the cake?"
    case orderSize1 = "For how many people would you like the cake? (1)"
    
    case cupcakesAmount = "How many cupcakes would you like?"
    case cupcakesAmount1 = "How many cupcakes would you like? (1)"
    
    case cakeFlavour = "Which flavour would you like the cake?"
    case cakeFlavour1to4 = "Which flavour would you like the cake? (1-4)"
    
    case cakeFilling = "Which flavour would you like the filling?"
    case cakeFilling1to4 = "Which flavour would you like the filling? (1-4)"
    
    case cakeTextAndColor = "Which text would you like on the cake and which colour?"
    case cakeTextType = "How would you like the text?"
    case phoneNumber = "Your Phone number (Optional)"
    case email = "Email"
    case extras = "Please provide extra information here"
    
}
struct SubmissionResponse: Codable {
    let responses: [Submission]
    let totalResponses: Int
    let pageCount: Int
}

struct FirebaseSubmission: Codable, Identifiable {
    @DocumentID var id: String? // Firebase will automatically generate an ID
    var submissionId: String
    var submissionTime: String
    var lastUpdatedAt: String
    var questions: [SubmissionQuestion]
    var isConfirmed: Bool = false
    var isDeleted: Bool = false
    var isViewed: Bool = false
    var isCompleted: Bool = false
    var isRead: Bool? = nil

    var submissionTimeDate: Date? {
        return ISO8601DateFormatter.extended.date(from: submissionTime)
    }
}

struct Submission: Codable, Identifiable {
    let submissionId: String
    var submissionTime: String
    var lastUpdatedAt: String
    var questions: [SubmissionQuestion]
    
    var id: String { submissionId }
    var submissionTimeDate: Date? {
        return ISO8601DateFormatter.extended.date(from: submissionTime)
    }
}

struct MappedSubmission: Codable, Identifiable {
    var collectionId: String
    let submissionId: String
    var submissionTime: String
    var lastUpdatedAt: String
    var questions: [SubmissionQuestion]
    var isConfirmed: Bool = false
    var isDeleted: Bool = false 
    var isViewed: Bool = false 
    var isCompleted: Bool = false
    var isRead: Bool = false

    var id: String { submissionId }
    var submissionTimeDate: Date? {
        return ISO8601DateFormatter.extended.date(from: submissionTime)
    }
}

struct SubmissionQuestion: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var type: String
    var value: ValueType?

    // Implement the `==` operator for custom equality checks
    static func == (lhs: SubmissionQuestion, rhs: SubmissionQuestion) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.value == rhs.value
    }

    // Implement the `hash(into:)` method to conform to `Hashable`
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(value)
    }
}

struct File: Codable, Hashable {
    var url: String
    var filename: String
}
enum SubError: Error {
    case error
}
enum ValueType: Codable, Equatable, Hashable {
    case string(String?)
    case array([String])
    case null
    case file([File])
    
    init(string: String) {
        if string.isEmpty {
            self = .null
        } else {
            self = .string(string)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let fileValue = try? container.decode([File].self) {
            self = .file(fileValue)
        } else if let arrayValue = try? container.decode([String].self) {
            self = .array(arrayValue)
        } else if let stringValue = try? container.decode(String?.self) {
            self = .string(stringValue)
        } else {
            // Try decoding the raw JSON data to understand the type that failed
            if let data = try? container.decode(Data.self),
               let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                print("Error decoding ValueType: Unrecognized data type. Raw JSON value: \(json)")
            } else {
                print("Error decoding ValueType: Unable to determine raw value.")
            }
            
            throw SubError.error
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .string(let stringValue):
            try container.encode(stringValue)
        case .array(let arrayValue):
            try container.encode(arrayValue)
        case .file(let fileValue):
            try container.encode(fileValue)
        }
    }
    
    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }

    var arrayValue: [String]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }

    var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }
}
