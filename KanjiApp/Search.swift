import Foundation
import UIKit

class Search : CustomUIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var discoverBarFade: UIImageView!
    let numberOfColumns = 7
    var timer: NSTimer? = nil
    let baseLife: Double = 20
    let randomLife: Double = 5
    let spawnInterval: Double = 1.7
    
    var currentTime: Double = 20
    var maxTime: Double = 140
    let frameRate: Double = 1 / 60
    let scrollSpeed: Double = 0.26
    let scrollDamping: Double = 0.9
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResults: UITableView!
    @IBOutlet weak var navigationBarLabel: UILabel!
    var searchResultsBaseFrame: CGRect = CGRect()
    @IBOutlet weak var discoverClickableArea: UIButton!
    var items: [NSNumber] = []
    var labels: [DiscoverLabel] = []
    var labelsData: [DiscoverLabelData] = []
    var scrollVelocity: Double = 0
    var touchesDown = false
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        searchResults.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchResultsBaseFrame = searchResults.frame
        
        for i in 0 ..< numberOfLabels {
            labels += DiscoverLabel(frame: CGRectMake(0, 0, 1, 1))
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(frameRate, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
        
        var gesture = UILongPressGestureRecognizer(target: self, action: "respondToLongPressGesture:")
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        discoverClickableArea.addGestureRecognizer(gesture)
        
        var tap = UITapGestureRecognizer(target: self, action: "onTouch:")
        tap.cancelsTouchesInView = false
        tap.delaysTouchesBegan = false
        tap.delaysTouchesEnded = false
        discoverClickableArea.addGestureRecognizer(tap)
        
        gesture.requireGestureRecognizerToFail(tap)
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onCloseKeyboard", object: nil)
        
//        Globals.notificationTransitionToView.addObserver(self, selector: "onCloseKeyboard", object: nil)
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "onCloseKeyboard", object: nil)
        
        onTimerTick()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func onTimerTick() {
        if searchBarTextChanged {
            searchBarTextChanged = false
            updateSearch(searchBar.text)
        }
        
        currentTime += scrollVelocity
        scrollVelocity *= scrollDamping
        
        if !touchesDown &&
            searchResults.hidden &&
            RootContainer.instance.sidebar.hidden &&
            !RootContainer.instance.mainView.hidden {
            currentTime += frameRate
        }
        maxTime = max(currentTime, maxTime)
        currentTime = max(currentTime, 0)
        
        if currentTime == 0 {
            scrollVelocity = 0//abs(scrollVelocity) * 0.5
        }
        
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
            let width: CGFloat = 42.0
            
            if !data.visible {
                
                data.visible = true
                label.textColor = UIColor(
                    red: CGFloat(data.distance * 0.4),
                    green: CGFloat(data.distance * 0.85),
                    blue: CGFloat(data.distance * 1),
                    alpha: 1)
                
                label.kanji = data.kanji
                label.attributedText = data.attributedText
                
                label.frame = CGRectMake(0, 0, width, data.height)
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
            let verticalOutset: CGFloat = 140
            
            var yOffset: CGFloat = (UIScreen.mainScreen().bounds.height + verticalOutset * 2) * localTime
            
            var xPos: CGFloat = xInset + (UIScreen.mainScreen().bounds.width - xInset * 2) / CGFloat(numberOfColumns) * CGFloat(data.column)
            label.frame = CGRectMake(
                xPos - label.frame.width / 2 + width / 2,
                -verticalOutset + yOffset - data.height / 2 - label.frame.height / 2 + data.height / 2,
                label.frame.width,
                label.frame.height)
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
    
    func onCloseKeyboard() {
        closeKeyboard()
    }
    
    func closeKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func onTouch(gesture: UIGestureRecognizer) {
        
        switch gesture.state {
        case .Began:
            touchesDown = true
        case .Ended:
            touchesDown = false
        default:
            break
        }
        
        if lastSearchText == "" {
            closeKeyboard()
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView!) {
        closeKeyboard()
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        println(self.items.count)
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
    
//    var startTouchLocation: CGPoint = CGPoint()
    var touchLocation: CGPoint = CGPoint()
    func respondToLongPressGesture(gesture: UILongPressGestureRecognizer) {
        
        closeKeyboard()
        
        switch gesture.state {
        case .Began:
            touchesDown = true
            touchLocation = gesture.locationInView(self.view)
//            startTouchLocation = touchLocation
            
        case .Ended:
            touchesDown = false
            
//            let maxDistance: CGFloat = 3
            
            touchLocation = gesture.locationInView(self.view)
 
//            if (touchLocation.x - startTouchLocation.x) * (touchLocation.y - startTouchLocation.y) < maxDistance * maxDistance {
//                onTouch(gesture)
//            }
        default:
            break
        }
        
        var pan = Double(gesture.locationInView(self.view).y - touchLocation.y)
        touchLocation = gesture.locationInView(self.view)
        
        pan /= 80
        pan *= scrollSpeed
        
        scrollVelocity += pan
        
//        currentTime = min(currentTime, maxTime)
        
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            if !isFront {
//                if let card = dueCard {
//                    switch swipeGesture.direction {
//                        
//                    case UISwipeGestureRecognizerDirection.Right:
//                        onInteract(.SwipeRight, card)
//                        
//                    case UISwipeGestureRecognizerDirection.Down:
//                        onInteract(.SwipeDown, card)
//                        
//                    case UISwipeGestureRecognizerDirection.Up:
//                        onInteract(.SwipeUp, card)
//                        
//                    case UISwipeGestureRecognizerDirection.Left:
//                        onInteract(.SwipeLeft, card)
//                        
//                    default:
//                        break
//                    }
//                }
//            }
//        }
    }
    
//    func setupSwipeGestures() {
////        println("add gestures")
//        
////        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToVerticalScrollGesture:")
////        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
////        self.discoverClickableArea.addGestureRecognizer(swipeDown)
//        
////        var pan = UIPanGestureRecognizer(target: self, action: "respondToPanGesture:")
////        pan.cancelsTouchesInView = false
////        pan.delaysTouchesBegan = false
////        pan.delaysTouchesEnded = false
//////        pan.direction = UISwipeGestureRecognizerDirection.Up
////        self.view.addGestureRecognizer(pan)
//    }
    
//    func searchBarShouldBeginEditing(searchBar: UISearchBar!) -> Bool {
//        println("searchBarShouldBeginEditing")
//
//        return true
//    }
//    
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar!) {
//        println("open search")
//        
//        //        searchResults.hidden = false
//        
//        //        searchResults.frame = CGRectMake(searchResultsBaseFrame.origin.x, UIScreen.mainScreen().bounds.height, searchResultsBaseFrame.width, searchResultsBaseFrame.height)
//    }
    
//    func searchBarTextDidEndEditing(searchBar: UISearchBar!) {
//        //        searchResults.hidden = true
//        println("did end editing")
////        searchBar.resignFirstResponder()
//    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
//        println("searchBarSearchButtonClicked")
        closeKeyboard()
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar!) -> Bool {
//        println("should end editing")
        closeKeyboard()
        
        return true
    }

//    func searchBar(searchBar: UISearchBar!, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        println("selectedScopeButtonIndexDidChange = \(searchBar.text)")
//    }
    
    var searchBarTextChanged = false
    
    func searchBar(searchBar: UISearchBar!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        
        searchBarTextChanged = true
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        println(searchText)
        
        updateSearch(searchText)
    }
    
    var lastSearchText = ""
    
    private func updateSearch(text: String) {
        lastSearchText = text
        
        let fadeSpeed: NSTimeInterval = 0.4
        
        if text != "" && searchResults.hidden {
            searchResults.hidden = false
            searchResults.alpha = 0
            
            UIView.animateWithDuration(fadeSpeed,
                delay: NSTimeInterval(),
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.searchResults.alpha = 1
                },
                completion: nil)
        } else if text == "" && !searchResults.hidden {
            
            UIView.animateWithDuration(fadeSpeed,
                delay: NSTimeInterval(),
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.searchResults.alpha = 0
                },
                completion: { (_) -> Void in self.searchResults.hidden = true})
        }
        
        if text != "" {
            //            searchBar.resignFirstResponder()
            
            var predicate = "(\(CardProperties.kanji.description()) BEGINSWITH[c] %@)OR(\(CardProperties.hiragana.description()) BEGINSWITH[c] %@)"//"\(CardProperties.kanji.description())==%@"
            
            var cards = managedObjectContext.fetchEntities(CoreDataEntities.Card, rawPredicate: (predicate, [text, text]), CardProperties.kanji)
            
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