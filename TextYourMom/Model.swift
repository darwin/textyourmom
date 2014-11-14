import UIKit

class Model {
    var silenced = 0
    var db : NSUserDefaults {
        get {
            return NSUserDefaults.standardUserDefaults()
        }
    }

    let introPlayedKey = "IntroPlayed"
    var introPlayed : Bool = false {
        didSet {
            onChange(introPlayedKey)
        }
    }
    
    let lastReportedAirportKey = "LastReportedAiport"
    var lastReportedAirport : String = "" {
        didSet {
            onChange(lastReportedAirportKey)
        }
    }

    let visitorStateKey = "VisitorState"
    var visitorState : String = "" {
        didSet {
            onChange(visitorStateKey)
        }
    }

    func onChange(reason: String) {
        if silenced != 0 {
            return
        }
        save(reason)
    }
    
    func silence(block: () -> Void) {
        silenced++
        block()
        silenced--
    }
    
    func load() {
        log("model: load")
        
        silence {
            if let val = self.db.objectForKey(self.introPlayedKey) as? Bool {
                self.introPlayed = val
            }
            if let val = self.db.objectForKey(self.lastReportedAirportKey) as? String {
                self.lastReportedAirport = val
            }
            if let val = self.db.objectForKey(self.visitorStateKey) as? String {
                self.visitorState = val
            }
        }
        
    }

    func save(reason: String) {
        log("model: save (reason: \(reason))")

        db.setBool(introPlayed, forKey: introPlayedKey)
        db.setObject(lastReportedAirport, forKey: lastReportedAirportKey)
        db.setObject(visitorState, forKey: visitorStateKey)

        db.synchronize()
    }
    
    func reset() {
        log("model: reset")

        let defaults = Model() // construct a pristine model
        introPlayed = defaults.introPlayed
        lastReportedAirport = defaults.lastReportedAirport
        visitorState = defaults.visitorState
        
        save("reset")
    }
    
    func dictionaryRepresentation() -> [NSString:AnyObject] {
        var res = [NSString:AnyObject]()
        res[introPlayedKey] = introPlayed
        res[lastReportedAirportKey] = lastReportedAirport
        res[visitorStateKey] = visitorState
        return res
    }
    
    func debugPrint() {
        let content = dictionaryRepresentation()
        log("model: \(content)")
    }
}