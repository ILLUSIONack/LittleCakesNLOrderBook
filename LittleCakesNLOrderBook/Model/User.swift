import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let createdAt: Date
    let updatedAt: Date
}

enum UserRole: String, Codable {
    case admin
    case user
}
