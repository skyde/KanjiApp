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
    
    @IBAction func studyAmountTapped(sender: UISegmentedControl) {
        
        switch numCardsToAdd.selectedSegmentIndex {
        case 1:
            RootContainer.instance.settings.cardAddAmount = 0
        case 3:
            RootContainer.instance.settings.cardAddAmount = 1
        case 5:
            RootContainer.instance.settings.cardAddAmount = 2
        case 10:
            RootContainer.instance.settings.cardAddAmount = 3
        case 20:
            RootContainer.instance.settings.cardAddAmount = 4
        default:
            break
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//    UITableViewHeaderFooterView.appearance().set
//        UIBarButtonItem.appearance().setTitleTextAttributes(<#attributes: [NSObject : AnyObject]!#>, forState: <#UIControlState#>)
//        UILabel.appearance().set
//        UILabel.appearanceForTraitCollection(<#trait: UITraitCollection!#>)
//        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:28]];
    }
    
//    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
//        
////        var label = super.tableView(tableView, viewForHeaderInSection: section)
////        
////        println(label)
////        
////        for subView in label.subviews {
////            println(subView)
////        }
//        
//        var label = UILabel()
//        label.frame = CGRectMake(20, 8, 320, 20)
//        label.font = UIFont(name: Globals.EnglishFont, size: 16)
//        label.text = tableView.headerViewForSection(<#section: Int#>)//self.tableView.headerViewForSection(0)
////        UILabel *myLabel = [[UILabel alloc] init];
////        myLabel.frame = CGRectMake(20, 8, 320, 20);
////        myLabel.font = [UIFont boldSystemFontOfSize:18];
////        myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//
//        var labelView = UIView()
//        labelView.addSubview(labelView)
//        
//        return label
////        
////        UIView *headerView = [[UIView alloc] init];
////        [headerView addSubview:myLabel];
////        
////        return headerView;
//
//    }
//
//    func func tableView(tableView: UITableView!, viewForFooterInSection section: Int) -> UIView! {
////        <#code#>
//    }
    
//    tablevi
//    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//    }
    
    var fontUpdated = false
    func updateFonts() {
        var success = false
        
        for i in 0 ..< tableView.numberOfSections() {
            var header = tableView.headerViewForSection(i)
            var footer = tableView.footerViewForSection(i)
//            var font: UIFont!
            
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
        
//        selectedSegmentIndex
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