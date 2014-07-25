//
//  Globals.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-21.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation

struct Globals
{
    static let JapaneseFont = "M+ 2p"//mplus-2p-regular
    
    static let JapaneseFontLight = "mplus-2p-light"
}

//func randomRange(max: Double) -> Double {
//    
//    return randomRange(0, max)
//}

func randomRange(min: Double, max: Double) -> Double {
    
    return min + (Double(arc4random())) / 0x100000000 * max
}
func randomRange(min: Int, max: Int) -> Int {
    
    var base:Double = Double(arc4random()) / 0x100000000
    
    return Int(Double(min) + (base * Double(max)))
}
//func randomRange(min: Double, max: Double, granularity: Int) -> Double {
//    
//    return min + round((Double(arc4random())) / 0x100000000 * Double(granularity)) / Double(granularity) * max
//}