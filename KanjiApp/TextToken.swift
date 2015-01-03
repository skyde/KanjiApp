import Foundation
import CoreData

class TextToken {
    init(_ text: String, hasDefinition: Bool, index: NSManagedObject! = nil) {
        self.text = text
        self.index = index
        self.hasDefinition = hasDefinition
    }
    
    var text: String
    var index: NSManagedObject!
    var hasDefinition: Bool
}
