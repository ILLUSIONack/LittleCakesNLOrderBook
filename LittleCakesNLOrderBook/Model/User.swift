import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let role: String
    let createdAt: Date
    let updatedAt: Date
}
