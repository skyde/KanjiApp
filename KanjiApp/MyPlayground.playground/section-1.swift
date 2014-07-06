// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var array: String[] = String[](count: 100, repeatedValue: "")

for var i = 0; i < array.count; i++ {
    
    array[i] = String(i)
}

for t in array {
    
    t
}


array