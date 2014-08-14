//
//  View.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-24.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation

enum View {
    case Search
    case GameMode
    case Reader
    case CardsFinished
    case AddWords(exclude: [WordList])
    case Lists(title: String, cards: [NSNumber])
    case Settings
    
    func description() -> String {
        switch self {
        case .Search:
            return "Search"
        case .GameMode:
            return "GameMode"
        case .Reader:
            return "Reader"
        case .CardsFinished:
            return "CardsFinished"
        case .AddWords:
            return "AddWords"
        case .Lists:
            return "Lists"
        case .Settings:
            return "Settings"
        }
    }
}