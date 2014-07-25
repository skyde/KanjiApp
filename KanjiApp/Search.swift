//
//  Search.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-24.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit

class Search : CustomUIViewController {
    
    @IBOutlet weak var discoverBarFade: UIImageView!
    let numberOfColumns = 7
//    var discoverLabels: [DiscoverAnimatedLabel] = []
    var timer:NSTimer? = nil
    var spawnedColumns: [Int] = []
    let baseLife: Double = 20
    let randomLife: Double = 30
//    init(coder aDecoder: NSCoder!) {
//        
//        super.init(coder: aDecoder)
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        discoverLabels.map { self.animateLabel($0) }
//        spawnedColumns = []
        var spawnInterval: Double = 1.5
        
        timer = NSTimer.scheduledTimerWithTimeInterval(spawnInterval, target: self, selector: "onSpawnTimerTick", userInfo: nil, repeats: true)
        
        let averageLife = baseLife + randomLife / 2
        for var i: Double = 0; i < averageLife; i += spawnInterval {
            spawnText(i / averageLife)
        }
    }
    
    func resetSpawnColumns() {
        
        spawnedColumns = []
        for var i = 0; i < numberOfColumns; i++ {
            spawnedColumns += i
        }
    }
    
    func selectRandomOpenColumn() -> Int {
        
        if spawnedColumns.count == 0 {
            resetSpawnColumns()
        }
//        spawnedColumns.f
//        var open = spawnedColumns.filter { $0 == false }
//        println(spawnedColumns.count)
//        
//        if open.count == 0 {
//            spawnedColumns = [Bool](count: spawnedColumns.count, repeatedValue: false)
//        }
        //
        var select = randomRange(0, spawnedColumns.count)
        
        var value = spawnedColumns[select]
        spawnedColumns.removeAtIndex(select)
        
        return value
    }
    
    func onSpawnTimerTick() {
        spawnText(0)
    }
    
    func spawnText(var time: Double) {
        
        let inset: Double = 10.0
        let width: Double = 30.0
        let height: CGFloat = 250
        let verticalOutset: CGFloat = 200
        
        var distance = randomRange(0.0, 1.0)
        distance = distance * distance
        
        var life: Double = (baseLife + randomLife * distance) * (1 - time)
        
        var targetColumn = selectRandomOpenColumn()
        var yOffset: CGFloat = (UIScreen.mainScreen().bounds.height + verticalOutset * 2) * CGFloat(time)
        
        var xPos = inset + (Double(UIScreen.mainScreen().bounds.width) - inset * 2) / Double(numberOfColumns) * Double(targetColumn)
        var label = DiscoverAnimatedLabel(frame: CGRectMake(CGFloat(xPos), -verticalOutset + yOffset, CGFloat(width), 200))
        
        if var card = fetchRandomCard() {
            label.text = card.kanji
        } else {
            if var card = fetchRandomCard() {
                label.text = card.kanji
            }
            else {
                label.text = "空"
            }
        }
        
        
        label.numberOfLines = 0
        label.font = UIFont(name: Globals.JapaneseFont, size: 24)
        label.textColor = UIColor(
            red: CGFloat(distance * 0.4),
            green: CGFloat(distance * 0.85),
            blue: CGFloat(distance * 1),
            alpha: 1)
        
        self.view.addSubview(label)
        self.view.sendSubviewToBack(label)
        
        UIView.animateWithDuration(life,
            delay: NSTimeInterval(),
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                label.frame = CGRectMake(label.frame.origin.x, UIScreen.mainScreen().bounds.height + verticalOutset, label.frame.width, label.frame.height)
            },
            completion: { (_) -> Void in label.removeFromSuperview() })
        
        
        var labels:[DiscoverAnimatedLabel] = []
        for item in self.view.subviews {
            if let label = item as? DiscoverAnimatedLabel {
                labels += label
            }
        }
        
        labels.sort { CGColorGetComponents($0.textColor.CGColor)[0] < CGColorGetComponents($1.textColor.CGColor)[0] }
        
        for label in labels {
            self.view.sendSubviewToBack(label)
        }
        self.view.sendSubviewToBack(discoverBarFade)
    }
//    void)myAnimationStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
//    {
    
    func fetchRandomCard() -> Card? {
        
        var rnd = Int(randomRange(1000, 9567))
        
        return managedObjectContext.fetchCardByIndex(rnd)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
//        discoverLabels = []
//        
//        for item in self.view.subviews {
//            if let label = item as? DiscoverAnimatedLabel {
//                
//                
//                label.removeFromSuperview()
//                
//                discoverLabels += add
//                self.animateLabel(add)
//            }
//        }
    }
    
//    func animateLabel(label: DiscoverAnimatedLabel) {
//        
//        println(label)
//            }
}