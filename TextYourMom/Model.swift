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

    let logsKey = "Logs"
    var logs : String = "" {
        didSet {
            onChange(nil) // deliberate no reason to prevent logging
        }
    }

    func onChange(reason: String?) {
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
            if let val = self.db.objectForKey(self.logsKey) as? String {
                self.logs = val
            }
        }
        
    }

    func save(reason: String?) {
        if reason != nil {
            log("model: save (reason: \(reason!))")
        }

        db.setBool(introPlayed, forKey: introPlayedKey)
        db.setObject(lastReportedAirport, forKey: lastReportedAirportKey)
        db.setObject(visitorState, forKey: visitorStateKey)
        db.setObject(logs, forKey: logsKey)

        db.synchronize()
    }
    
    func reset() {
        log("model: reset")

        silence {
            let defaults = Model() // construct a pristine model
            self.introPlayed = defaults.introPlayed
            self.lastReportedAirport = defaults.lastReportedAirport
            self.visitorState = defaults.visitorState
            self.logs = defaults.logs
        }
        
        save("reset")
    }
    
    func dictionaryRepresentation() -> [NSString:AnyObject] {
        var res = [NSString:AnyObject]()
        res[introPlayedKey] = introPlayed
        res[lastReportedAirportKey] = lastReportedAirport
        res[visitorStateKey] = visitorState
        let len = countElements(logs)
        res[logsKey] = "\(len) chars"
        return res
    }
    
    func debugPrint() {
        let content = dictionaryRepresentation()
        log("model: \(content)")
    }
}