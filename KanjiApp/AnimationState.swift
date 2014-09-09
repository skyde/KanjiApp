import Foundation

public enum AnimationState {
    case Closed
    case Opening
    case Open
    case Closing
    case DraggingOpen
    case DraggingClosed
    
    public func IsOpenOrClosed() -> Bool {
        switch self {
        case Open:
            return true
        case Closed:
            return true
        default:
            return false
        }
    }
    
    public func IsAnimating() -> Bool {
        switch self {
        case Opening:
            return true
        case Closing:
            return true
        default:
            return false
        }
    }
    
    public func IsDragging() -> Bool {
        switch self {
        case DraggingOpen:
            return true
        case DraggingClosed:
            return true
        default:
            return false
        }
    }
    
    public func AnyOpen() -> Bool {
        switch self {
        case Open:
            return true
        case Opening:
            return true
        case DraggingOpen:
            return true
        default:
            return false
        }
    }
    
    public static func GetCompletion(open: Bool) -> AnimationState {
        if open {
            return AnimationState.Open
        } else {
            return AnimationState.Closed
        }
    }
    
    public static func GetAnimating(open: Bool) -> AnimationState {
        if open {
            return AnimationState.Opening
        } else {
            return AnimationState.Closing
        }
    }
    
    public static func GetDrag(isDraggingOpen: Bool) -> AnimationState {
        if isDraggingOpen {
            return AnimationState.DraggingOpen
        } else {
            return AnimationState.DraggingClosed
        }
    }
}
