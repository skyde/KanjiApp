import Foundation
import UIKit
import SpriteKit
//import PaRomajiKanaConverter
//import PaRomajiKanaConverter
//#import "UCTypingPhraseManager.h"

class Search : CustomUIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var discoverBarFade: UIImageView!
    let numberOfColumns = 7
    var timer: NSTimer? = nil
    let baseLife: Double = 20
    let randomLife: Double = 5
    let spawnInterval: Double = 1.7
    
    let maxNumberOfLabels: Int = 64
    var currentMinLabel: Int = 0
    
    var currentTime: Double = 20
    var maxTime: Double = 140
    let frameRate: Double = 1 / 60
    let scrollSpeed: Double = 0.26
    let scrollDamping: Double = 0.9
    
    var columnFinishTime:[CGFloat] = []
    
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
//    var currentMinTime: Double = 0

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

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        columnFinishTime = []
        
        for i in 0 ..< numberOfColumns {
            columnFinishTime.append(CGFloat(randomRange(0.0, 0.001)))
        }

        self.automaticallyAdjustsScrollViewInsets = false
        
        searchResults.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchResultsBaseFrame = searchResults.frame
        
        for i in 0 ..< numberOfLabels {
            var add = DiscoverLabel(frame: CGRectMake(0, 0, 1, 1))
            
            add.onTouch = { (label) in println(label.kanji) }
            
            labels.append(add)
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(frameRate, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
        
        var gesture = UILongPressGestureRecognizer(target: self, action: "onDown:")
        gesture.minimumPressDuration = 0
        gesture.delegate = self
        discoverClickableArea.addGestureRecognizer(gesture)
        
        var onTap = UITapGestureRecognizer(target: self, action: "onTap:")
        onTap.delegate = self
        view.addGestureRecognizer(onTap)
        
        //        self.addGestureRecognizer(gesture)

//        gesture.cancelsTouchesInView = false
//        gesture.delaysTouchesBegan = false
//        gesture.delaysTouchesEnded = false
        
//        tap.cancelsTouchesInView = false
//        tap.delaysTouchesBegan = false
//        tap.delaysTouchesEnded = false
        
//        gesture.requireGestureRecognizerToFail(tap)
        
        onTimerTick()
    }
    
    var touchLocation: CGPoint = CGPoint()
    func onDown(gesture: UILongPressGestureRecognizer) {
        
        closeKeyboard()
        
        switch gesture.state {
        case .Began:
            touchesDown = true
            touchLocation = gesture.locationInView(self.view)
            
        case .Ended:
            touchesDown = false
            
            touchLocation = gesture.locationInView(self.view)
        default:
            break
        }
        
        var pan = Double(gesture.locationInView(self.view).y - touchLocation.y)
        touchLocation = gesture.locationInView(self.view)
        
        pan /= 80
        pan *= scrollSpeed
        
        scrollVelocity += pan
    }

    func onTap(gesture: UITapGestureRecognizer) {
        closeKeyboardIfSearchIsEmpty()
        
        var tapLocation = gesture.locationInView(self.view)
        if Globals.notificationShowDefinition.value == "" {
            var matches: [DiscoverLabel] = []
            
            for label in labels {
                var frame = label.layer.presentationLayer()?.frame
                
                if let frame = frame {
                    if CGRectContainsPoint(CGRectMake(frame.origin.x - 15, frame.origin.y, frame.width + 20, frame.height), tapLocation) {
                        matches.append(label)
                    }
                }
            }
            
            if matches.count > 0 {
                var match = matches.sorted {
                    $0.depth < $1.depth
                    }[0]
                
                var duration: NSTimeInterval = 0.4
                var outset: CGFloat = 2
                
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
            }
        }
    }
    

    override func addNotifications() {
        super.addNotifications()
        
        Globals.notificationShowDefinition.addObserver(self, selector: "onCloseKeyboard", object: nil)
        
        Globals.notificationSidebarInteract.addObserver(self, selector: "onCloseKeyboard", object: nil)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
        return true
    }
    
    func onTimerTick() {
        if searchBar.text != lastSearchText {
            updateSearch(searchBar.text)
        }
        
        currentTime += scrollVelocity
        scrollVelocity *= scrollDamping
        
        if !touchesDown &&
            searchResults.hidden &&
            RootContainer.instance.sidebar.hidden &&
            !RootContainer.instance.mainView.hidden &&
            RootContainer.instance.definitionOverlay.hidden {
            currentTime += frameRate
        }
        
        var minTime = Double(currentMinLabel) * spawnInterval
        
        maxTime = max(currentTime, maxTime)
        currentTime = max(currentTime, minTime)
        
        if currentTime == minTime {
            scrollVelocity = 0
        }
        
        if labelsData.count > maxNumberOfLabels {
            var remove = labelsData.removeAtIndex(0)
            currentMinLabel++
        }
        
        var first = Int(currentTime / spawnInterval - 0)
        var last = first + numberOfLabels
        
        while last > labelsData.count + currentMinLabel {
            labelsData.append(spawnLabelData(Double(labelsData.count + currentMinLabel) * spawnInterval - averageLife))
        }
        
        for i in 0 ..< labels.count {
            let label = labels[i]
            var index = i - first % labels.count
            if index < 0 {
                index += labels.count
            }
            let dataIndex = first + index
            let dataLookup = dataIndex - currentMinLabel
            
            if dataLookup < 0 {
                continue
            }
            
            let data = labelsData[dataIndex - currentMinLabel]
            let width: CGFloat = 42
            
            if !data.visible {
                data.visible = true
                
                label.setupLabelFromData(data, width: 42)
                
                self.view.addSubview(label)
                self.view.sendSubviewToBack(label)
                
                for label in (labels.sorted {
                    $0.depth < $1.depth }) {
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
        
        columnFinishTime[value.column] = value.startTime + value.life
        
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
    
    func closeKeyboardIfSearchIsEmpty() {
        if lastSearchText == "" {
            closeKeyboard()
        }
    }
        override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        searchResults.hidden = true
    }
    
    func selectRandomOpenColumn() -> Int {
        var column: Int?
        var smallestValue: CGFloat = CGFloat.infinity
        
        for i in 0 ..< columnFinishTime.count {
            var value = columnFinishTime[i]
            
            if smallestValue > value {
                column = i
                smallestValue = value
            }
        }
        
        return column!
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        closeKeyboard()
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar!) -> Bool {
        closeKeyboard()
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        updateSearch(searchText)
    }
    
    var lastSearchText = ""
    var romajiConverter = PaRomajiKanaConverter()
    
    private func updateSearch(text: String) {
        lastSearchText = text
        
        let fadeSpeed: NSTimeInterval = 0.3
        
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
                delay: 0.5,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    self.searchResults.alpha = 0
                },
                completion: { (_) -> Void in self.searchResults.hidden = true })
        }
        
        if text != "" {
            
            var fromRomaji = romajiConverter.convertToHiraganaFromRomaji(text)
            
            var predicate =
            "(\(CardProperties.kanji.description()) BEGINSWITH[c] %@)OR(\(CardProperties.hiragana.description()) BEGINSWITH[c] %@)OR(\(CardProperties.hiragana.description()) BEGINSWITH[c] %@)OR(\(CardProperties.definition.description()) CONTAINS[c] %@)"
            
            var cards = managedObjectContext.fetchEntities(CoreDataEntities.Card, rawPredicate: (predicate, [text, text, fromRomaji, text]), CardProperties.kanji)
            
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