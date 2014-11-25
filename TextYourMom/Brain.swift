import UIKit

protocol BrainDelegate {
    func remindCallMomFromAirport(city:String, _ airportName:String)
}

class Brain {
    
    var delegate: BrainDelegate?
    var state = AirportsVisitorState()

    init() {
        
    }
    
    func reportAirportVisit(airportId: AirportId) {
        if let airport = masterController.airportsProvider.lookupAirport(airportId) {
            model.lastReportedAirport = airport.name
            delegate?.remindCallMomFromAirport(airport.city, airport.name)
        } else {
            log("unable to lookup airport #\(airportId)")
        }
    }
}

// MARK: AirportsWatcherDelegate
extension Brain : AirportsWatcherDelegate {
    
    func visitorPotentialChangeInState(newState: AirportsVisitorState) {
        let diff = AirportsVisitorStateDiff(oldState:state, newState:newState)
        
        if diff.empty {
            return
        }
        
        log("brain: state changed \(diff)")
        
        state = newState
        
        // new state should be stored in the model
        model.visitorState = state.serialize()
        
        if supressNextStateChangeReport {
            log("supressNextStateChangeReport active => bail out")
            supressNextStateChangeReport = false
            return
        }
        
        // we are only interested in airports where user was suddenly teleported in
        // in other words: the airport state changed from .None to .Inner
        var candidates = [AirportId]()
        for (id, change) in diff.diff {
            if change.before == .None && change.after == .Inner {
                candidates.append(id)
            }
        }
        
        if candidates.count == 0 {
            log("  no teleportations detected => bail out")
            return
        }
        
        // in case we got multiple simultaneous teleportations
        // report only airport with lowest id
        candidates.sort({$0 < $1})
        log("  got candidates \(candidates), reporting the first one")
        reportAirportVisit(candidates[0])
    }
    
}
