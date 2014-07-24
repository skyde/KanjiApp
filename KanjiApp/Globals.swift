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
    static let JapaneseFont = "M+ 2p"
}

//func randomRange(max: Double) -> Double {
//    
//    return randomRange(0, max)
//}

func randomRange(min: Double, max: Double) -> Double {
    
    return min + (Double(arc4random())) / 0x100000000 * max
}