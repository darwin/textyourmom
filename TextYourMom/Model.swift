import UIKit

class Model {
    var db : NSUserDefaults {
        get {
            return NSUserDefaults.standardUserDefaults()
        }
    }

    let introPlayedKey = "IntroPlayed"
    var introPlayed = false
    
    let lastReportedAirportKey = "LastReportedAiport"
    var lastReportedAirport = ""

    func load() {
        log("model: load")

        if let val = db.objectForKey(introPlayedKey) as? Bool {
            introPlayed = val
        }
        if let val = db.objectForKey(lastReportedAirportKey) as? String {
            lastReportedAirport = val
        }
    }

    func save() {
        log("model: save")

        db.setBool(introPlayed, forKey: introPlayedKey)
        db.setObject(lastReportedAirport, forKey: lastReportedAirportKey)

        db.synchronize()
    }
    
    func reset() {
        log("model: reset")
        let defaults = Model() // construct a pristine model
        
        introPlayed = defaults.introPlayed
        lastReportedAirport = defaults.lastReportedAirport
        
        save()
    }
    
    func debugPrint() {
        save()
        let content = db.dictionaryRepresentation()
        log("DB: \(content)")
    }
}