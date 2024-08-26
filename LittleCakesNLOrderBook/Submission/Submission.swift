import Foundation
import FirebaseFirestore

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
    let submissionId: String
    var submissionTime: String
    var lastUpdatedAt: String
    var questions: [SubmissionQuestion]
    var isConfirmed: Bool = false

    var id: String { submissionId }
    var submissionTimeDate: Date? {
        return ISO8601DateFormatter.extended.date(from: submissionTime)
    }
}

struct SubmissionQuestion: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let type: String
    let value: ValueType?

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

enum ValueType: Codable, Equatable, Hashable {
    case string(String?)
    case array([String])
    case null
    case file([File])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Check if the value is null
        if container.decodeNil() {
            self = .null
        } else if let stringValue = try? container.decode(String?.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([String].self) {
            self = .array(arrayValue)
        } else if let fileValue = try? container.decode([File].self) {
            self = .file(fileValue)
        } else {
            self = .string("tt")
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
