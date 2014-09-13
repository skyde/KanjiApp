import Foundation
import UIKit

class SettingsTableView: UITableViewController, UITableViewDelegate {
//    @IBOutlet var table: UITableView!
//    @IBOutletCollection var headersAndFooters: [UILabel]!
//    @IBOutlet var headersAndFooters: Array<UILabel>!
    @IBOutlet weak var volume: UISlider!
    @IBOutlet weak var numCardsToAdd: UISegmentedControl!
    @IBAction func onVolumeChanged(sender: UISlider) {
//        println("onVolumeChanged")

        SettingsView.instance.onVolumeChanged(sender)

    }
    @IBAction func onBackupTapped(sender: AnyObject) {
//        println("onBackupTapped")
        SettingsView.instance.onBackupTap(sender)
    }
    @IBOutlet weak var tutorialButtonSwitch: UISwitch!
    
    @IBOutlet weak var sidebarButtonSwitch: UISwitch!
    
    
    @IBAction func studyAmountTapped(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            RootContainer.instance.settings.cardAddAmount = 1
        case 1:
            RootContainer.instance.settings.cardAddAmount = 3
        case 2:
            RootContainer.instance.settings.cardAddAmount = 5
        case 3:
            RootContainer.instance.settings.cardAddAmount = 10
        case 4:
            RootContainer.instance.settings.cardAddAmount = 20
        default:
            break
        }
        
        RootContainer.instance.saveContext()
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
        volume.value = RootContainer.instance.settings.volume.floatValue
        
        updateFonts()
        
        // 1, 3, 5, 10, 20
        switch RootContainer.instance.settings.cardAddAmount {
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
        
        tutorialButtonSwitch.on = !RootContainer.instance.settings.hideTutorialButton.boolValue
        
        sidebarButtonSwitch.on = !RootContainer.instance.settings.hideSidebarButton.boolValue
        //        selectedSegmentIndex
    }
    @IBAction func showTutorialButtonValueChanged(sender: UISwitch)
    {
        RootContainer.instance.settings.hideTutorialButton = !sender.on
        RootContainer.instance.saveContext()
    }
    @IBAction func showSidebarButtonValueChanged(sender: UISwitch) {
        RootContainer.instance.settings.hideSidebarButton = !sender.on
        RootContainer.instance.saveContext()
    }
//        super.viewDidAppear(animated)
//        for i in 0 ..< table.numberOfSections() {
//            if let header = table.headerViewForSection(i) {
//                header.textLabel.font = UIFont(name: Globals.JapaneseFont, size: 16)
//                header.textLabel.textColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
//                //                header.textLabel.textAlignment = NSTextAlignment.Left
//                header.backgroundView.backgroundColor = bkColor
//                
//                //                header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, header.frame.width, 10)
//            }
//        }    }
//
//        println(table)
//        println(table.numberOfSections())
//        
//        for i in 0 ..< table.numberOfSections() {
//            if let header = table.footerViewForSection(i) {
//                println(header)
//            }
//        }
////        table.headerViewForSection(0).textLabel.font = UIFont(name: Globals.EnglishFont, size: 16)
//    }
}