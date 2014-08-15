import Foundation

public class Notification<T> {
    init (_ id: String, _ defaultValue: T) {
        self.id = id
        self.value = defaultValue
    }
    
    public var id: String
    public var value: T
    
    public func postNotification(value: T) {
        self.value = value
        
        NSNotificationCenter.defaultCenter().postNotificationName(id, object: nil)
    }
    
    public func addObserver(observer: AnyObject!, selector: Selector, object: AnyObject! = nil) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: id, object: object)
    }
    
//    public func getObject(notification: NSNotification) -> T {
//        return (notification.object as Container<T>).Value
//    }
}