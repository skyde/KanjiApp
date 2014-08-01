import Foundation

class TextToken {
    init(_ text: String, hasDefinition: Bool, index: Int = -1) {
        self.text = text
        self.index = index
        self.hasDefinition = hasDefinition
    }
    
    var text: String
    var index: Int
    var hasDefinition: Bool
}
