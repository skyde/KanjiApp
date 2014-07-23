import Foundation
import UIKit
import CoreData

class SettingsView: CustomUIViewController {
    
    @IBOutlet var volume: UISlider!
    
    @IBAction func onVolumeChanged(sender: AnyObject) {
        settings.volume = volume.value
        saveContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        volume.value = settings.volume.floatValue
    }
}