import Foundation
import FirebaseFirestore


struct SubmissionResponse: Codable {
    let responses: [Submission]
    let totalResponses: Int
    let pageCount: Int
}

struct FirebaseSubmission: Codable, Identifiable {
    @DocumentID var id: String?
    var submissionId: String
    var submissionTime: String
    var lastUpdatedAt: String
    var questions: [SubmissionQuestion]
    var type: SubmissionType
    var state: SubmissionState
    var isDelegated: Bool? = false

    var submissionTimeDate: Date? {
        return ISO8601DateFormatter.extended.date(from: submissionTime)
    }
}

enum SubmissionType: String, Codable, CaseIterable {
    case new = "new"
    case confirmed = "confirmed"
    case completed = "completed"
    case deleted = "deleted"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = SubmissionType(rawValue: rawValue) ?? .new // Default to `.new`
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

enum SubmissionState: String, Codable {
    case unviewed = "unviewed"
    case viewed = "viewed"
    case messaged = "messaged"

    // Custom initializer for handling unknown values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = SubmissionState(rawValue: rawValue) ?? .unviewed // Default to `.unviewed`
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

struct MappedSubmission: Codable, Identifiable {
    var collectionId: String
    let submissionId: String
    var submissionTime: String
    var lastUpdatedAt: String
    var questions: [SubmissionQuestion]
    var type: SubmissionType
    var state: SubmissionState
    var isDelegated: Bool? = false

    var id: String { submissionId }
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
