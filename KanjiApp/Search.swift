import Foundation
import UIKit

class Search : CustomUIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var discoverBarFade: UIImageView!
    let numberOfColumns = 7
    var timer: NSTimer? = nil
//    var spawnedColumns: [Int] = []
    let baseLife: Double = 20
    let randomLife: Double = 5
    let spawnInterval: Double = 1.7
    
    var currentTime = 0.0
    var frameRate = 1.0 / 60.0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResults: UITableView!
    @IBOutlet weak var navigationBarLabel: UILabel!
    var searchResultsBaseFrame: CGRect = CGRect()
    @IBOutlet weak var discoverClickableArea: UIButton!
    var items: [NSNumber] = []
    var labels: [DiscoverAnimatedLabel] = []
    
    var averageLabelLife: Double {
    get {
        return baseLife + randomLife / 2
    }
    }
    var numberOfLabels: Int {
    get {
        return Int(averageLabelLife / spawnInterval)
    }
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
//        items = []
//        labels = []
    }
    
//    var animatedLabels : [DiscoverAnimatedLabel]
//    {
//    get {
//        var labels:[DiscoverAnimatedLabel] = []
//        for item in self.view.subviews {
//            if let label = item as? DiscoverAnimatedLabel {
//                labels += label
//            }
//        }
//        
//        return labels
//    }
//    }
    
    
//    init(coder aDecoder: NSCoder!) {
//        super.init(coder: aDecoder)
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                for i in 0 ..< numberOfLabels {
            var add = DiscoverAnimatedLabel(frame: CGRectMake(0, 0, 1, 1))
            labels += add
            spawnLabel(add, time: Double(i) / Double(numberOfLabels))
        }

        self.automaticallyAdjustsScrollViewInsets = false
        
        searchResults.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchResultsBaseFrame = searchResults.frame
        
//        lastSpawned = Array(count: numberOfColumns, repeatedValue: nil)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(frameRate, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
        
        var gesture = UILongPressGestureRecognizer(target: self, action: "onTouch:")
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesEnded = false
        discoverClickableArea.addGestureRecognizer(gesture)
    }
    
    func onTimerTick() {
        currentTime += frameRate
        
        for label in labels {
            label.frame.origin.y += 0.3
        }
//        spawnText(0)
    }
    
    func onTouch(gesture: UIGestureRecognizer) {
        
        if lastSearchText == "" {
            searchBar.resignFirstResponder()
        }
        
        var tapLocation = gesture.locationInView(self.view)
        if Globals.notificationShowDefinition.value == "" {
            var matches: [DiscoverAnimatedLabel] = []
            
            for label in labels {
                var frame = label.layer?.presentationLayer()?.frame
                
                if let frame = frame {
                    if CGRectContainsPoint(frame, tapLocation) {
                        matches += label
                    }
                }
            }
            
            if matches.count > 0 {
                var match = matches.sorted {
                    CGColorGetComponents($0.textColor.CGColor)[0] < CGColorGetComponents($1.textColor.CGColor)[0]
                    }[0]
                
                var duration: NSTimeInterval = 0.4
                var outset: CGFloat = 6
                
                UIView.animateWithDuration(duration,
                    delay: NSTimeInterval(),
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {
                        match.transform = CGAffineTransformMakeScale(outset, outset)
                        match.alpha = 0
                    },
                    completion: {
                        (_) -> Void in
                        match.transform = CGAffineTransformMakeScale(1, 1)
                        match.alpha = 1
                    })
                
                Globals.notificationShowDefinition.postNotification(match.kanji)
                
//                Globals.currentDefinition =
//                NSNotificationCenter.defaultCenter().postNotificationName(Globals.notificationShowDefinition, object: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchResults.hidden = true
//        Globals.currentDefinition == ""
        
//        for var i: Double = 0; i < Double(numberOfColumns); i += spawnInterval {
//            let life = 0.95 + i / Double(numberOfColumns) * 0.05
//            spawnText(life, distributionRandom: true)
//        }
        
    }
    
//    func resetSpawnColumns() {
//        spawnedColumns = []
//        for var i = 0; i < numberOfColumns; i++ {
//            spawnedColumns += i
//        }
//    }
    
    func selectRandomOpenColumn() -> Int {
//        if spawnedColumns.count == 0 {
//            resetSpawnColumns()
//        }
        
        return randomRange(0, numberOfColumns)
        
//        var value = spawnedColumns[select]
//        spawnedColumns.removeAtIndex(select)
//        
//        return value
    }
    
    
    func spawnLabel(var label: DiscoverAnimatedLabel, var time: Double) {
        let inset: Double = 10.0
        let width: Double = 42.0
        let verticalOutset: CGFloat = 100
        
        var targetColumn = selectRandomOpenColumn()
        
        var distance = randomRange(0.0, 1.0)
        distance = distance * distance
        
        var life: Double = (baseLife + randomLife * distance) * (1 - time)

        var yOffset: CGFloat = (UIScreen.mainScreen().bounds.height + verticalOutset * 2) * CGFloat(time)
        
        var xPos = inset + (Double(UIScreen.mainScreen().bounds.width) - inset * 2) / Double(numberOfColumns) * Double(targetColumn)
        label.frame = CGRectMake(CGFloat(xPos), -verticalOutset + yOffset, CGFloat(width), 200)
        
        var card = fetchRandomCard()
        
        if card == nil {
            card = fetchRandomCard()
        }
        
        if card == nil {
            card = managedObjectContext.fetchCardByKanji("空")
        }
        
        if let card = card {
            var size: CGFloat = 30
            
            label.kanji = card.kanji
            label.attributedText = card.animatedLabelText(size)
            let height = size * (CGFloat(countElements(card.kanji)) + 1)
            
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.width, height)
        }
        label.column = targetColumn
        
        label.numberOfLines = 0
        
        label.textColor = UIColor(
            red: CGFloat(distance * 0.4),
            green: CGFloat(distance * 0.85),
            blue: CGFloat(distance * 1),
            alpha: 1)
        
        self.view.addSubview(label)
        self.view.sendSubviewToBack(label)
        
//        UIView.animateWithDuration(life,
//            delay: NSTimeInterval(),
//            options: UIViewAnimationOptions.CurveLinear,
//            animations: {
//                label.frame = CGRectMake(label.frame.origin.x, UIScreen.mainScreen().bounds.height + 5, label.frame.width, label.frame.height)
//            },
//            completion: {
//                (_) -> Void in
//                label.removeFromSuperview();
////                if self.lastSpawned[label.column] == label {
////                    self.lastSpawned[label.column] = nil
////                }
//            })
        
//        var l =
        
        for label in (labels.sorted {
            CGColorGetComponents($0.textColor.CGColor)[0] < CGColorGetComponents($1.textColor.CGColor)[0]
        }) {
            self.view.sendSubviewToBack(label)
        }
        
        self.view.sendSubviewToBack(discoverBarFade)
        
//        lastSpawned[label.column] = label
    }
    
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        println(self.items.count)
        return self.items.count;
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell = searchResults.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row]) {
            
            cell.textLabel.attributedText = card.cellText
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        if var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row]) {
            Globals.notificationShowDefinition.postNotification(card.kanji)
        }
    }
    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar!) {
        println("open search")
        
        //        searchResults.hidden = false
        
        //        searchResults.frame = CGRectMake(searchResultsBaseFrame.origin.x, UIScreen.mainScreen().bounds.height, searchResultsBaseFrame.width, searchResultsBaseFrame.height)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar!) {
        //        searchResults.hidden = true
        println("did end editing")
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar!) -> Bool {
        println("should end editing")
        //        searchBar.resignFirstResponder()
        //        searchBar.
        
        return true
    }
    
    var lastSearchText = ""
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        lastSearchText = searchText
        
        let fadeSpeed: NSTimeInterval = 0.4
        
        if searchText != "" && searchResults.hidden {
            searchResults.hidden = false
            searchResults.alpha = 0
            
            UIView.animateWithDuration(fadeSpeed,
                delay: NSTimeInterval(),
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.searchResults.alpha = 1
                },
                completion: nil)
        } else if searchText == "" && !searchResults.hidden {
            
            UIView.animateWithDuration(fadeSpeed,
                delay: NSTimeInterval(),
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.searchResults.alpha = 0
                },
                completion: { (_) -> Void in self.searchResults.hidden = true})
        }
        
        if searchText != "" {
            searchBar.resignFirstResponder()
            
            var predicate = "(\(CardProperties.kanji.description()) BEGINSWITH[c] %@)OR(\(CardProperties.hiragana.description()) BEGINSWITH[c] %@)"//"\(CardProperties.kanji.description())==%@"
            
            var cards = managedObjectContext.fetchEntities(CoreDataEntities.Card, rawPredicate: (predicate, [searchText, searchText]), CardProperties.kanji)
            
            items = cards.map { ($0 as Card).index }
            
            searchResults.reloadData()
        }
    }
    
    func fetchRandomCard() -> Card? {
        var rnd = Int(randomRange(1000, 9567))
        
        return managedObjectContext.fetchCardByIndex(rnd)
    }
}