import UIKit

protocol BrainDelegate {
    func remindCallMomFromAirport(city:String, _ airportName:String)
}

class Brain {
    
    var delegate: BrainDelegate?

    init() {
        
    }
}

// MARK: events
extension Brain {
    
    func enteredAiport(perimeter:AirportPerimeter, _ city:String, _ airportName:String) {
        log("entered airport \(airportName) in \(city)")
        if perimeter == .Outer {
            if model.lastVisitedPlace == airportName {
                log("entered outer perimeter from inner perimeter => skip airport reporting (leaving the airport)")
                return
            }
            model.lastVisitedPlace = airportName
            log("entered outer perimeter => skip airport reporting")
            return
        } else { // .Inner perimeter
            if model.lastVisitedPlace == airportName {
                log("already reported => prevent duplicit airport reporting")
                return
            }
            model.lastVisitedPlace = airportName
            model.lastReportedAirport = airportName
            delegate?.remindCallMomFromAirport(city, airportName)
        }
    }
    
    func enteredNoMansLand() {
        log("entered no-mans-land => reset lastVisitedAiport")
        model.lastVisitedPlace = ""
    }
}