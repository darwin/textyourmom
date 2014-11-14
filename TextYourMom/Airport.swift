typealias AirportId = Int

enum AirportPerimeter : String {
    case None = "none"
    case Inner = "inner"
    case Outer = "outer"
}

struct Airport {
    var id: AirportId = 0
    var name: String = ""
    var city: String = ""
    var country: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}

class AirportsVisitorState : Equatable, Printable {
    var state = [AirportId:AirportPerimeter]()
    
    func update(id:AirportId, _ perimeter: AirportPerimeter) {
        if perimeter == .None {
            state[id] = nil
            return
        }
        state[id] = perimeter
    }
    
    func itemDescription(id:AirportId, _ perimeter: AirportPerimeter) -> String {
        return "\(id):\(perimeter.rawValue)"
    }
    
    var description: String {
        if state.count == 0 {
            return "[no man's land]"
        }
        
        var parts = [String]()
        for (id, perimeter) in state {
            parts.append(itemDescription(id, perimeter))
        }
        return ", ".join(parts)
    }
}

// MARK: serialization
extension AirportsVisitorState {
    
    func serialize() -> String {
        var parts = [String]()
        for (id, perimeter) in state {
            parts.append("\(id):\(perimeter.rawValue)")
        }
        return ",".join(parts)
    }
    
    func unserialize(data: String) {
        state.removeAll(keepCapacity: true)
        let items = split(data) {$0 == ","}
        for item in items {
            let pieces = split(item) {$0 == ":"}
            if pieces.count != 2 {
                log("unable to unserialize pair: \(item)")
                continue
            }
            
            let id = pieces[0].toInt()
            let perimeter = AirportPerimeter.init(rawValue:pieces[1])
            
            if id != nil && perimeter != nil {
                state[id!] = perimeter!
            } else {
                log("unable to unserialize pair: \(item)")
            }
        }
    }
    
}

func ==(lhs: AirportsVisitorState, rhs: AirportsVisitorState) -> Bool {
    return lhs.state == rhs.state
}

struct AirportVisitChange {
    var before: AirportPerimeter
    var after: AirportPerimeter
}

class AirportsVisitorStateDiff : Printable {
    var diff = [AirportId:AirportVisitChange]()
    
    init(oldState: AirportsVisitorState, newState:AirportsVisitorState) {
        let oldIds = $.keys(oldState.state)
        let newIds = $.keys(newState.state)
        
        for id in $.difference(oldIds, newIds) {
            diff[id] = AirportVisitChange(before:oldState.state[id]!, after:.None)
        }
        for id in $.difference(newIds, oldIds) {
            diff[id] = AirportVisitChange(before:.None, after:newState.state[id]!)
        }
        for id in $.intersection(newIds, oldIds) {
            let change = AirportVisitChange(before:oldState.state[id]!, after:newState.state[id]!)
            if change.before != change.after {
                diff[id] = change
            }
        }
    }
    
    var description: String {
        if diff.count == 0 {
            return "- no change -"
        }
        
        var parts = [String]()
        for (id, change) in diff {
            parts.append("\(id):\(change.before.rawValue)->\(change.after.rawValue)")
        }
        return ", ".join(parts)
    }
    
    var empty : Bool {
        return diff.count == 0
    }
}