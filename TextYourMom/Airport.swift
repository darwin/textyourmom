import Dollar

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
    
    var description: String {
        if state.count == 0 {
            return "[no man's land]"
        }
        
        var parts = [String]()
        for (id, perimeter) in state {
            parts.append("#\(id)(\(perimeter.rawValue))")
        }
        return ", ".join(parts)
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
            diff[id] = AirportVisitChange(before:oldState.state[id]!, after:newState.state[id]!)
        }
    }
    
    var description: String {
        if diff.count == 0 {
            return "- no change -"
        }
        
        var parts = [String]()
        for (id, change) in diff {
            parts.append("#\(id)(\(change.before.rawValue)->\(change.after.rawValue))")
        }
        return ", ".join(parts)
    }
}