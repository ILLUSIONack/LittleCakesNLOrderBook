import Foundation
import EventKit

final class EventStoreManager {
    // Singleton instance
    static let shared = EKEventStore()
    
    // Private initializer to prevent additional instances
    private init() {}
}
