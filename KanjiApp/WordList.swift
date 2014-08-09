import Foundation

enum WordList {
    case MyWords
    case Jlpt4
    case Jlpt3
    case Jlpt2
    case Jlpt1
    case AllWords
//    case List([NSNumber])
    
    func description() -> String {
        switch self {
        case .MyWords:
            return "My Words"
        case .Jlpt4:
            return "JLPT 4"
        case .Jlpt3:
            return "JLPT 3"
        case .Jlpt2:
            return "JLPT 2"
        case .Jlpt1:
            return "JLPT 1"
        case .AllWords:
            return "All Words"
//        case .List:
//            return "List"
        }
    }
}