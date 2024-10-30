import Foundation
import EventKit

final class EventStoreManager {
    static let shared = EKEventStore()
    
    private init() {}
}
