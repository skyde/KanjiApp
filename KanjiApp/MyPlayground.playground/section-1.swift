// Playground - noun: a place where people can play

import UIKit

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}

func trimEntryExcess(var value: String) -> String {
    if value == "" {
        return value
    }
    
    let length = countElements(value)
    
    if length >= 2 {
        value[0..<1]
        value[length - 1..<length]
        
        if  value[0..<1] == "\"" &&
            value[length - 1..<length] == "\"" {
                value = value[1..<length-1]
        }
    }
    
    return value
}


var test = "\"空かなたHello\""

trimEntryExcess(test)

var t = ""
for var i = 0; i < 100; i++ {
    var s = "\(test) + \(i)"
    t += s
}

t

var x = "\"test"

x

x = x[0..<2]

x

