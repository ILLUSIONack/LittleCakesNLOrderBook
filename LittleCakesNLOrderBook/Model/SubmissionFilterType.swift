import Foundation

enum SubmissionFilterType: CaseIterable {
    case newAndConfirmed
    case new
    case confirmed
    case completed
    case deleted
    
    var displayName: String {
        switch self {
        case .newAndConfirmed: return "All"
        case .new: return "New"
        case .confirmed: return "Confirmed"
        case .completed: return "Completed"
        case .deleted: return "Deleted"
        }
    }
    
    var submissionTypes: [SubmissionType] {
        switch self {
        case .newAndConfirmed: return [.new, .confirmed]
        case .new: return [.new]
        case .confirmed: return [.confirmed]
        case .completed: return [.completed]
        case .deleted: return [.deleted]
        }
    }
}

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
