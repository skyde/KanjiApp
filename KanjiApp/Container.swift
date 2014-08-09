import Foundation

class Container<T> {
    init(_ value: T) {
        Value = value
    }
    
    var Value: T
}