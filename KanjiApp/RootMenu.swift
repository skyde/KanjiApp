import Foundation

class RootMenu: CustomUIViewController {
    
    override var isGameView: Bool {
    get {
        return false
    }
    }
    
    override var alwaysReceiveNotifications: Bool {
    get {
        return true
    }
    }
//    
//    override func receiveTransitionToViewNotifications() -> Bool {
//        return true
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
    var targetView: View = .Search
    override func onTransitionToView(notification: NSNotification) {
//        println("RootMenu onTransitionToView \(notification)")
        if let targetView = (notification.object as? Container<View>)?.Value {
            self.targetView = targetView
//            println("RootMenu \(targetView)")
        }
    }
//    override onTransitionToView
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        performSegueWithIdentifier(targetView.description(), sender: self)
    }
}