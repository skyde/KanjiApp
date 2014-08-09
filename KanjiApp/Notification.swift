import Foundation

class Notification<T: AnyObject> {
    init (_ id: String) {
        self.id = id
    }
    
    public var id: String
    
    public func postNotification(value: T) {
        NSNotificationCenter.defaultCenter().postNotificationName(id, object: value)
    }
    
    public func addObserver(observer: AnyObject!, selector: Selector, object: AnyObject! = nil) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: id, object: object)
    }
    
    public func getObject(notification: NSNotification) -> T {
        return notification.object as T
    }
}