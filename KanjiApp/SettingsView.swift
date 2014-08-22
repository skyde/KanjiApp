import Foundation
import UIKit
import CoreData

class SettingsView: CustomUIViewController {
    
    @IBOutlet var volume: UISlider!
    
    @IBAction func onVolumeChanged(sender: AnyObject) {
        settings.volume = volume.value
        saveContext()
    }
    
    @IBAction func onBackupTap(sender: AnyObject) {
        println("backup")
//        managedObjectContext.
        println(self.exportUserList())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        volume.value = settings.volume.floatValue
    }
}