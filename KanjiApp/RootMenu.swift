import Foundation

class RootMenu: CustomUIViewController {
    
//    var hasInitalTransitioned = false
//
//    override func viewWillAppear(animated: Bool) {
//        println("viewWillAppear")
    //    }
    override var isGameView: Bool {
        get {
            return false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        hasInitalTransitioned = true
        performSegueWithIdentifier(Globals.notificationTransitionToView.value.description(), sender: self)
    }
    
//    override func viewDidLayoutSubviews() {
//        if !hasInitalTransitioned {
//            hasInitalTransitioned = true
//            performSegueWithIdentifier(Globals.notificationTransitionToView.value.description(), sender: self)
//        }
//    }
}