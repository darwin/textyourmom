import UIKit

enum AppState {
    case NoLocation
    case NoNotifications
    case NoLocationAndNotifications
    case Normal
    case Intro
    case Error(String)
}

class MasterController {
    
    var airportsProvider = AirportsProvider()
    var airportsWatcher = AirportsWatcher()
    var brain = Brain()
    var executor = Executor()
    var introPlayed = false
    
    func boot() -> Bool {
        brain.delegate = executor // executor will resond to brain decisions
        log("Parsing airports...")
        airportsProvider.parseFromResource("airports")
        log("  ... resolved \(airportsProvider.airports.count) airports")
        log("Registering airports with airports watcher...")
        airportsWatcher.delegate = self
        airportsWatcher.registerAirports(airportsProvider)

        // do not call refreshApp() here, EmptyController's animation might be in-flight
        // see EmptyController.viewDidAppear()
        
        return true
    }
    
    func playIntro() -> Bool {
        return !introPlayed
    }
    
    func detectAppState() -> AppState {
        if playIntro() {
            return .Intro
        }
        
        if !airportsWatcher.isLocationMonitoringAvailable() {
            return .Error("Location monitoring is not available on this device")
        }
        
        let locationsApproved = airportsWatcher.hasRequiredAuthorizations()
        let notificationsApproved = executor.hasRequiredNotificationSettings()
        
        if !locationsApproved && !notificationsApproved {
            return .NoLocationAndNotifications
        }
        if !locationsApproved {
            return .NoLocation
        }
        if !notificationsApproved {
            return .NoNotifications
        }

        return .Normal
    }
    
    func refreshApp(_ overrideState:AppState? = nil) {
        if !emptyControllerReady {
            return
        }
        var state = overrideState
        if state == nil {
            state = detectAppState()
        }
        log("Refresh app with state \(state)")
        switch state! {
        case .Normal:
            executor.setupNotifications()
            airportsWatcher.start() // TODO: check for errors?
            switchToScreen("Main")
        case .NoLocation:
            airportsWatcher.stop()
            switchToScreen("NoLocation")
        case .NoNotifications:
            airportsWatcher.stop()
            switchToScreen("NoNotifications")
        case .NoLocationAndNotifications:
            airportsWatcher.stop()
            switchToScreen("NoLocationAndNotifications")
        case .Intro:
            airportsWatcher.stop()
            switchToScreen("Intro")
        case let .Error(err):
            log("Error: \(err)")
            let errorController = switchToScreen("Error") as ErrorController
            errorController.initializers.append({
                let this = $0 as ErrorController
                this.message.text = err
                this.message.setNeedsDisplay()
            })
        }
    }
    
    func confirmIntro() {
        introPlayed = true
        airportsWatcher.requestRequiredAuthorizations()
        executor.setupNotifications()
        
        // above calls are non-blocking, UI will react indirectly
        // additionally we do manual refreshApp() for case calls above had no effect
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), { self.refreshApp() })
        
    }
}

// MARK: AirportsWatcherDelegate
extension MasterController : AirportsWatcherDelegate {
    
    func enteredAirport(airportId:Int) {
        log("enteredAirport #\(airportId)")
        if let airport = airportsProvider.lookupAirport(airportId) {
            brain.enteredAiport(airport.city, airport.name)
        } else {
            // TODO: DCHECK
        }
    }
    
    func enteredNoMansLand() {
        log("enteredNoMansLand")
    }
    
    func authorizationStatusChanged() {
        refreshApp()
    }
}
