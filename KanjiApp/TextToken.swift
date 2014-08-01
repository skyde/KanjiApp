import Foundation

class TextToken {
    init(_ text: String, _ index: Int, hasDefinition: Bool) {
        self.text = text
        self.index = index
        self.hasDefinition = hasDefinition
    }
    
    var text: String
    var index: Int
    var hasDefinition: Bool
}
