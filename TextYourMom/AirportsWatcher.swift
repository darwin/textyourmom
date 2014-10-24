import CoreLocation

enum AirportPerimeter : String {
    case Inner = "inner"
    case Outer = "outer"
}

protocol AirportsWatcherDelegate {
    func enteredAirport(id:Int, _ perimeter:AirportPerimeter)
    func enteredNoMansLand()
    func authorizationStatusChanged()
}

class AirportsWatcher: NSObject {
    var locationManager: CLLocationManager = CLLocationManager()
    var delegate: AirportsWatcherDelegate?
    var regions: [CLCircularRegion] = []
    var lastAirportSignature : Int = 0 // 0 means no airport, positive are inner perimeters, negative are outer perimeters
    var lastLatitude : Double = 0
    var lastLongitude : Double = 0
 
    override init() {
        super.init()
        locationManager.delegate = self
        // TODO: investigate locationManager.allowDeferredLocationUpdatesUntilTraveled
        //locationManager.allowDeferredLocationUpdatesUntilTraveled(2000*1000, timeout: CLTimeIntervalMax) // 2000 km
    }
    
    func registerAirports(airportsProvider: AirportsProvider) {
        func buildOuterRegionFromAirport(airport: Airport) -> CLCircularRegion {
            let center = CLLocationCoordinate2D(latitude:airport.latitude, longitude:airport.longitude)
            let radius = CLLocationDistance(outerAirportPerimeterDistance)
            let id = String(airport.id)
            let region = CLCircularRegion(center: center, radius: radius, identifier: id)
            return region;
        }
        
        let airports = airportsProvider.airports
        for airport in airports {
            var region = buildOuterRegionFromAirport(airport)
            regions.append(region)
        }
    }
    
    func isLocationMonitoringAvailable() -> Bool {
        return CLLocationManager.significantLocationChangeMonitoringAvailable()
    }
    
    func hasRequiredAuthorizations() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        log("CLLocationManager.authorizationStatus() returned \(status.rawValue) (expected 3)")
        return status.rawValue == 3 // Swift problem: .AuthorizedAlways is missing
    }
    
    func requestRequiredAuthorizations() {
        if (ios8()) {
            log("requestAlwaysAuthorization")
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func start() {
        log("AirportsWatcher start");
        if inSimulator() {
            // startMonitoringSignificantLocationChanges does not work in simulator, see http://stackoverflow.com/a/6213528
            locationManager.startUpdatingLocation()
        } else {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stop() {
        log("AirportsWatcher stop");
        if inSimulator() {
            locationManager.stopUpdatingLocation()
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
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
    
    func airportPerimeter(region:CLCircularRegion, _ latitude:Double, _ longitude:Double) -> AirportPerimeter {
        func buildInnerRegion(region:CLCircularRegion) -> CLCircularRegion {
            let center = region.center
            let radius = CLLocationDistance(innerAirportPerimeterDistance)
            let id = region.identifier
            let region = CLCircularRegion(center: center, radius: radius, identifier: id)
            return region;
        }
        let coord = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        let innerRegion = buildInnerRegion(region)
        if innerRegion.containsCoordinate(coord) {
            return .Inner
        } else {
            return .Outer
        }
    }
    
    func airportSignature(id:Int, _ perimeter:AirportPerimeter) -> Int {
        switch perimeter {
        case .Inner:
            return id
        case .Outer:
            return -id
        }
    }
    
    func processLocationReport(location: CLLocation, native: Bool = true) {
        if location.coordinate.latitude == lastLatitude && location.coordinate.longitude == lastLongitude {
            return
        }
        
        let age = location.timestamp.timeIntervalSinceNow
        log("Location update \(location.coordinate.latitude), \(location.coordinate.longitude) accuracy=\(location.horizontalAccuracy) age=\(age)")
        
        lastLatitude = location.coordinate.latitude
        lastLongitude = location.coordinate.longitude

        if native && overrideLocation>0 {
            log("overrideLocation is effective => bail out")
            return
        }
        
        if let region = hitTest(location.coordinate.latitude, location.coordinate.longitude) {
            let perimeter = airportPerimeter(region, location.coordinate.latitude, location.coordinate.longitude)
            let id = region.identifier.toInt()!
            let signature = airportSignature(id, perimeter)
            if lastAirportSignature != signature {
                lastAirportSignature = signature
                delegate?.enteredAirport(id, perimeter)
            }
        } else {
            if  lastAirportSignature != 0 {
                lastAirportSignature = 0
                delegate?.enteredNoMansLand()
            }
        }
    }
    
    func emitFakeUpdateLocation(latitude: Double, _ longitude:Double) {
        processLocationReport(CLLocation(latitude:latitude, longitude:longitude), native:false)
    }
}

// MARK: CLLocationManagerDelegate
extension AirportsWatcher : CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]!) {
        for location in locations {
            processLocationReport(location)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        lastError = "iOS LocationManager:\n\(error.localizedDescription)"
        masterController.refreshApp(AppState.Error)
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        log("Location updating was paused")
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        log("Location updating was resumed")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        log("didChangeAuthorizationStatus \(status.rawValue)")
        delegate?.authorizationStatusChanged()
    }
}

