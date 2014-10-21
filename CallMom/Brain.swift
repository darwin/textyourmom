import UIKit

protocol BrainDelegate {
    func remindCallMomFromAirport(city:String, _ airportName:String)
}

class Brain {
    
    var delegate: BrainDelegate?
    var lastVisitedAirport: String = ""

    init() {
        
    }
}

// MARK: events
extension Brain {
    
    func enteredAiport(city:String, _ airportName:String) {
        log("entered airport \(airportName) in \(city)")
        if lastVisitedAirport == airportName {
            log("Prevented duplicit airport reporting")
            return
        }
        lastVisitedAirport = airportName
        delegate?.remindCallMomFromAirport(city, airportName)
    }
    
}