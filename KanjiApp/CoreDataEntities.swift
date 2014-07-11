import Foundation
import UIKit
import CoreData

enum CoreDataEntities {
    case Card
    case Settings
    func description() -> String {
        switch self {
        case .Card:
            return "Card"
        case .Settings:
            return "Settings"
        }
    }
}
