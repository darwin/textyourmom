import CoreLocation

protocol AirportsWatcherDelegate {
    func enteredAirport(id:Int)
    func enteredNoMansLand()
}

class AirportsWatcher: NSObject {
    var locationManager: CLLocationManager = CLLocationManager()
    var delegate: AirportsWatcherDelegate?
    var regions: [CLCircularRegion] = []
    var lastAirport : Int = 0 // 0 means no airport
    
    override init() {
        super.init()
        locationManager.delegate = self
        // TODO: investigate locationManager.allowDeferredLocationUpdatesUntilTraveled
        //locationManager.allowDeferredLocationUpdatesUntilTraveled(2000*1000, timeout: CLTimeIntervalMax) // 2000 km
    }
    
    func registerAirports(airportsProvider: AirportsProvider) {
        func buildRegionFromAirport(airport: Airport) -> CLCircularRegion {
            let center = CLLocationCoordinate2D(latitude:airport.latitude, longitude:airport.longitude)
            let radius = CLLocationDistance(10*1000) // 10km TODO: read this from settings
            let id =  String(airport.id)
            let region = CLCircularRegion(center: center, radius: radius, identifier: id)
            return region;
        }
        
        let airports = airportsProvider.airports
        for airport in airports {
            var region = buildRegionFromAirport(airport)
            regions.append(region)
        }
    }
    
    func isLocationMonitoringAvailable() -> Bool {
        return CLLocationManager.significantLocationChangeMonitoringAvailable()
    }
    
    func hasRequiredAuthorizations() -> Bool {
        return CLLocationManager.authorizationStatus()==CLAuthorizationStatus.Authorized
    }
    
    func requestRequiredAuthorizations() {
        if (ios8()) {
            NSLog("AirportsWatcher: request authorization")
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func start() -> Bool {
        if !hasRequiredAuthorizations() {
            requestRequiredAuthorizations()
        }
        if !hasRequiredAuthorizations() {
            return false
        }
        
        NSLog("AirportsWatcher: start");

        if inSimulator() {
            // startMonitoringSignificantLocationChanges does not work in simulator
            // see http://stackoverflow.com/a/6213528
            locationManager.startUpdatingLocation()
        } else {
            locationManager.startMonitoringSignificantLocationChanges()
        }

        return true
    }
    
    func stop() -> Bool {
        NSLog("AirportsWatcher: stop");
        if inSimulator() {
            locationManager.stopUpdatingLocation()
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        return true
    }
    
    func hitTest(latitude:Double, _ longitude:Double) -> CLCircularRegion? {
        let coord = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        for region in regions {
            if region.containsCoordinate(coord) {
                return region
            }
        }
        return nil
    }
}

// MARK: CLLocationManagerDelegate
extension AirportsWatcher : CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]!) {
        for location in locations {
            let age = location.timestamp.timeIntervalSinceNow
            NSLog("AirportsWatcher: Location update \(location.coordinate.latitude), \(location.coordinate.longitude) accuracy=\(location.horizontalAccuracy) age=\(age)")
            
            if let region = hitTest(location.coordinate.latitude, location.coordinate.longitude) {
                let id = region.identifier.toInt()!
                if lastAirport != id {
                    lastAirport = id
                    delegate?.enteredAirport(id)
                }
            } else {
                if  lastAirport != 0 {
                    lastAirport = 0
                    delegate?.enteredNoMansLand()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("AirportsWatcher: Location update failed: \(error.localizedDescription)")
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        NSLog("AirportsWatcher: Location updating was paused")
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        NSLog("AirportsWatcher: Location updating was resumed")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        NSLog("AirportsWatcher: didChangeAuthorizationStatus \(status.rawValue)")
    }
}

