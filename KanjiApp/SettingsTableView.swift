import Foundation
import UIKit

class SettingsTableView: UITableViewController, UITableViewDelegate {
    
    @IBOutlet weak var volume: UISlider!
    @IBOutlet weak var numCardsToAdd: UISegmentedControl!
    
    @IBOutlet weak var displayRomaji: UISwitch!
    
    @IBOutlet weak var undoShortcut: UISwitch!
    
    private var settings: Settings {
    get {
        return RootContainer.instance.settings
    }
    }
    
    private func saveContext() {
        RootContainer.instance.saveContext()
    }
    
    @IBAction func onVolumeChanged(sender: UISlider) {
        SettingsView.instance.onVolumeChanged(sender)

    }
    @IBAction func onBackupTapped(sender: AnyObject) {
        SettingsView.instance.onBackupTap(sender)
    }
    @IBOutlet weak var tutorialButtonSwitch: UISwitch!
    
    @IBOutlet weak var sidebarButtonSwitch: UISwitch!
    
    
    @IBAction func studyAmountTapped(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            settings.cardAddAmount = 1
        case 1:
            settings.cardAddAmount = 3
        case 2:
            settings.cardAddAmount = 5
        case 3:
            settings.cardAddAmount = 10
        case 4:
            settings.cardAddAmount = 20
        default:
            break
        }
        
        saveContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    var fontUpdated = false
    func updateFonts() {
        var success = false
        
        for i in 0 ..< tableView.numberOfSections() {
            var header = tableView.headerViewForSection(i)
            var footer = tableView.footerViewForSection(i)
            
            if header != nil || footer != nil {
                var attribute = [
                    "NSFontNameAttribute" : Globals.EnglishFont,
                    "NSCTFontUIUsageAttribute" : UIFontTextStyleBody]
                var descriptor: UIFontDescriptor! = UIFontDescriptor(fontAttributes: attribute)
                
                if let item = header {
                    item.textLabel.font = UIFont(descriptor: descriptor, size: item.textLabel.font.pointSize)
                    success = true
                }
                
                if let item = footer {
                    item.textLabel.font = UIFont(descriptor: descriptor, size: item.textLabel.font.pointSize)
                    item.textLabel.numberOfLines = 0
                    var frame = item.textLabel.frame
                    item.textLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frame.height + 20)
                    success = true
                }
            }
        }
        
        if success {
            fontUpdated = true
        } else {
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateFonts", userInfo: nil, repeats: false)
        }
    }
    override func viewDidAppear(animated: Bool) {
        volume.value = settings.volume.floatValue
        
        updateFonts()
        
        // 1, 3, 5, 10, 20
        switch settings.cardAddAmount {
        case 1:
            numCardsToAdd.selectedSegmentIndex = 0
        case 3:
            numCardsToAdd.selectedSegmentIndex = 1
        case 5:
            numCardsToAdd.selectedSegmentIndex = 2
        case 10:
            numCardsToAdd.selectedSegmentIndex = 3
        case 20:
            numCardsToAdd.selectedSegmentIndex = 4
        default:
            break
        }
        
        tutorialButtonSwitch.on = !settings.hideTutorialButton.boolValue
        sidebarButtonSwitch.on = !settings.hideSidebarButton.boolValue
        undoShortcut.on = settings.undoSwipeEnabled.boolValue
        displayRomaji.on = settings.romajiEnabled.boolValue
    }
    @IBAction func showTutorialButtonValueChanged(sender: UISwitch)
    {
        settings.hideTutorialButton = !sender.on
        saveContext()
    }
    @IBAction func showSidebarButtonValueChanged(sender: UISwitch) {
        settings.hideSidebarButton = !sender.on
        saveContext()
    }
    @IBAction func undoShortcutValueChanged(sender: UISwitch) {
        settings.undoSwipeEnabled = sender.on
        saveContext()
    }
    @IBAction func displayRomajiValueChanged(sender: UISwitch) {
        settings.romajiEnabled = sender.on
        saveContext()
    }
}