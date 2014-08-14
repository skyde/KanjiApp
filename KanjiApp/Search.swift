import Foundation
import UIKit

class DiscoverLabelData {
    public var visible = false
    public var kanji = ""
    public var startTime: CGFloat = 0.0
    public var life: CGFloat = 0.0
    public var distance = 0.0
    public var column = 0
    public var attributedText: NSAttributedString? = nil
    public var height: CGFloat = 0
}

class Search : CustomUIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var discoverBarFade: UIImageView!
    let numberOfColumns = 7
    var timer: NSTimer? = nil
    let baseLife: Double = 20
    let randomLife: Double = 5
    let spawnInterval: Double = 1.7
    
    var currentTime = 0.0
    var maxTime = 0.0
    var frameRate = 1.0 / 60.0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResults: UITableView!
    @IBOutlet weak var navigationBarLabel: UILabel!
    var searchResultsBaseFrame: CGRect = CGRect()
    @IBOutlet weak var discoverClickableArea: UIButton!
    var items: [NSNumber] = []
    var labels: [DiscoverLabel] = []
    var labelsData: [DiscoverLabelData] = []
    
    var averageLife: Double {
    get {
        return baseLife + randomLife / 2
    }
    }
    var maxLife: Double {
    get {
        return baseLife + randomLife
    }
    }
    
    var numberOfLabels: Int {
    get {
        return Int(averageLife / spawnInterval)
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
        
        for i in 0 ..< numberOfLabels {
            labels += DiscoverLabel(frame: CGRectMake(0, 0, 1, 1))
        }
    }
    
    func onTimerTick() {
        currentTime += frameRate
        maxTime = max(currentTime, maxTime)
        currentTime = max(currentTime, 0)
        
        var first = Int(currentTime / spawnInterval)
        var last = first + numberOfLabels
        
        while last > labelsData.count {
            labelsData += spawnLabelData(Double(labelsData.count) * spawnInterval - averageLife)
        }
        
        for i in 0 ..< labels.count {
            let label = labels[i]
            var index = i - first % labels.count
            if index < 0 {
                index += labels.count
            }
            let dataIndex = first + index
            let data = labelsData[dataIndex]
            
            if !data.visible {
                data.visible = true
                label.textColor = UIColor(
                    red: CGFloat(data.distance * 0.4),
                    green: CGFloat(data.distance * 0.85),
                    blue: CGFloat(data.distance * 1),
                    alpha: 1)
                
                label.kanji = data.kanji
                label.attributedText = data.attributedText
                
//                label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.width, data.height)
                
                self.view.addSubview(label)
                self.view.sendSubviewToBack(label)
                
                for label in (labels.sorted {
                    CGColorGetComponents($0.textColor.CGColor)[0] < CGColorGetComponents($1.textColor.CGColor)[0]
                    }) {
                        self.view.sendSubviewToBack(label)
                }
                
                self.view.sendSubviewToBack(discoverBarFade)
            }
            
            let localTime: CGFloat = (CGFloat(currentTime) - data.startTime) / data.life
            
            let xInset: CGFloat = 10.0
            let width: CGFloat = 42.0
            let verticalOutset: CGFloat = 140
            
            var yOffset: CGFloat = (UIScreen.mainScreen().bounds.height + verticalOutset * 2) * localTime
            
            var xPos: CGFloat = xInset + (UIScreen.mainScreen().bounds.width - xInset * 2) / CGFloat(numberOfColumns) * CGFloat(data.column)
            label.frame = CGRectMake(xPos, -verticalOutset + yOffset - data.height / 2, width, data.height)
        }
    }
    
    func spawnLabelData(var time: Double) -> DiscoverLabelData {
        let value = DiscoverLabelData()
        
        var textSize: CGFloat = 30
        
        let card = fetchRandomCard()
        var random = randomRange(0.0, 1.0)
        random = random * random
        
        value.startTime = CGFloat(time)
        value.life = CGFloat(baseLife + randomLife * random)
        value.distance = random
        value.column = selectRandomOpenColumn()
        
        value.kanji = card.kanji
        value.attributedText = card.animatedLabelText(textSize)
        value.height = textSize * (CGFloat(countElements(card.kanji)) + 1)
        
        return value
    }
    
    func onTouch(gesture: UIGestureRecognizer) {
        
        if lastSearchText == "" {
            searchBar.resignFirstResponder()
        }
        
        var tapLocation = gesture.locationInView(self.view)
        if Globals.notificationShowDefinition.value == "" {
            var matches: [DiscoverLabel] = []
            
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
    
    func fetchRandomCard() -> Card {
        var rnd = Int(randomRange(1000, 9567))
        
        var value = managedObjectContext.fetchCardByIndex(rnd)
        
        if value == nil {
            value = fetchRandomCard()
        }
        
        return value!
    }
}