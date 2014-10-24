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
    
    func enteredAiport(perimeter:AirportPerimeter, _ city:String, _ airportName:String) {
        log("entered airport \(airportName) in \(city)")
        if perimeter == .Outer {
            lastVisitedAirport = airportName
            log("entered outer perimeter => skip airport reporting")
            return
        }
        
        if lastVisitedAirport == airportName {
            log("already reported => prevent duplicit airport reporting")
            return
        }
        lastVisitedAirport = airportName
        delegate?.remindCallMomFromAirport(city, airportName)
    }
}