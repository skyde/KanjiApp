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
    case AddWords
    case Lists
    
    func description() -> String {
        switch self {
        case .Search:
            return "Search"
        case .GameMode:
            return "GameMode"
        case .Reader:
            return "Reader"
        case .AddWords:
            return "AddWords"
        case .Lists:
            return "Lists"
        }
    }
}