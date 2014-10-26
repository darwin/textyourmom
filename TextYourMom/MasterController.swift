import UIKit

enum AppState : String {
    case NoLocation = "NoLocation"
    case NoNotifications = "NoNotifications"
    case NoLocationAndNotifications = "NoLocationAndNotifications"
    case Normal = "Normal"
    case Intro = "Intro"
    case Error = "Error"
}

class MasterController {
    
    var airportsProvider = AirportsProvider()
    var airportsWatcher = AirportsWatcher()
    var brain = Brain()
    var executor = Executor()
    
    func boot() -> Bool {
        model.load()
        brain.delegate = executor // executor will resond to brain decisions
        log("Parsing airports...")
        airportsProvider.parseFromResource("airports")
        log("  ... resolved \(airportsProvider.airports.count) airports")
        log("Registering airports with airports watcher...")
        airportsWatcher.delegate = brain
        airportsWatcher.registerAirports(airportsProvider)

        // do not call refreshApp() here, EmptyController's animation might be in-flight
        // see EmptyController.viewDidAppear()
        
        return true
    }
    
    func tearDown() {
        log("tear down")
        model.save()
        airportsWatcher.stop()
    }
    
    func playIntro() -> Bool {
        return !model.introPlayed
    }
    
    func detectAppState() -> AppState {
        if playIntro() {
            return .Intro
        }
        
        if !airportsWatcher.isLocationMonitoringAvailable() {
            lastError = stringLocationMonitoringIsNotAvailableError()
            return .Error
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
        log("Refresh app to state '\(state!.rawValue)'")
        switch state! {
        case .Normal:
            executor.setupNotifications()
            airportsWatcher.start()
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
        case .Error:
            log("Error: \(lastError)")
            let errorController = switchToScreen("Error") as ErrorController
            errorController.initializers.append({
                let this = $0 as ErrorController
                this.message.text = lastError
                this.message.setNeedsDisplay()
            })
        }
    }
    
    func confirmIntro() {
        model.introPlayed = true
        airportsWatcher.requestRequiredAuthorizations()
        executor.setupNotifications()
        
        // above calls are non-blocking, UI will react indirectly
        // additionally we do manual refreshApp() for case calls above had no effect
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), { self.refreshApp() })
        
    }
}