import Foundation
import UIKit

class SettingsTableView: UITableViewController, UITableViewDelegate {
//    @IBOutlet var table: UITableView!
//    @IBOutletCollection var headersAndFooters: [UILabel]!
//    @IBOutlet var headersAndFooters: Array<UILabel>!
    
    
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
    
//    var timer: NSTimer!
    var fontUpdated = false
    func updateFonts() {
        var success = false
        
//        println(UIFont.fontNamesForFamilyName(Globals.EnglishFont))
        
        for i in 0 ..< tableView.numberOfSections() {
            var header = tableView.headerViewForSection(i)
            var footer = tableView.footerViewForSection(i)
            var font: UIFont!
            
            if header != nil || footer != nil {
                var attribute = [
                    "NSFontNameAttribute" : Globals.EnglishFont,
                    "NSCTFontUIUsageAttribute" : UIFontTextStyleBody]
//                var attributes: [(NSObject : AnyObject)] = 
                var descriptor: UIFontDescriptor! = UIFontDescriptor(fontAttributes: attribute)
                font = UIFont(descriptor: descriptor, size: 13)
//                font = UIFont(name: Globals.EnglishFont, size: 13)
//                [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithFontAttributes:@{@"NSCTFontUIUsageAttribute" : UIFontTextStyleBody,
//                    @"NSFontNameAttribute" : @"Avenir-Light"}] size:14.0]
            }
            
            if let item = header {
                item.textLabel.font = font
                success = true
            }
            
            if let item = footer {
                item.textLabel.font = font
                success = true
            }
        }
        
        println("run")
        if success {
            println("success")
            
            fontUpdated = true
        } else {
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateFonts", userInfo: nil, repeats: false)
        }
    }
    override func viewDidAppear(animated: Bool) {
        updateFonts()
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