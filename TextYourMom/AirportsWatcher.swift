import CoreLocation

protocol AirportsWatcherDelegate {
    func visitorPotentialChangeInState(newState: AirportsVisitorState)
}

class AirportsWatcher: NSObject {
    var locationManager: CLLocationManager = CLLocationManager()
    var delegate: AirportsWatcherDelegate?
    var regions: [CLCircularRegion] = []
 
    override init() {
        super.init()
        locationManager.delegate = self
        if allowDeferredLocationUpdates {
            locationManager.allowDeferredLocationUpdatesUntilTraveled(allowDeferredLocationUpdatesUntilTraveledDistance, timeout: CLTimeIntervalMax)
        }
        // these settings should be relevant only when not using useSignificantLocationChanges
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 500
        locationManager.activityType = .OtherNavigation
    }
    
    func registerAirports(airportsProvider: AirportsProvider) {
        func buildOuterRegionFromAirport(airport: Airport) -> CLCircularRegion {
            let center = CLLocationCoordinate2D(latitude:airport.latitude, longitude:airport.longitude)
            let radius = CLLocationDistance(outerAirportPerimeterDistance)
            let id = String(airport.id)
            let region = CLCircularRegion(center: center, radius: radius, identifier: id)
            return region
        }
        
        let airports = airportsProvider.airports
        for airport in airports {
            var region = buildOuterRegionFromAirport(airport)
            regions.append(region)
        }
    }
    
    func hasRequiredAuthorizations() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        log("CLLocationManager.authorizationStatus() returned \(status.rawValue) (expected 3)")
        return status.rawValue == 3 // Swift problem: .AuthorizedAlways is missing
    }
    
    func requestRequiredAuthorizations() {
        if SINCE_IOS8 {
            log("requestAlwaysAuthorization")
            locationManager.requestAlwaysAuthorization()
        } else {
            if !hasRequiredAuthorizations() {
                // this is the way how to trigger system popup for allowing locations under iOS7
                log("enable/disable location manager to trigger system popup under iOS7")
                if useSignificantLocationChanges {
                    locationManager.startMonitoringSignificantLocationChanges()
                    locationManager.stopMonitoringSignificantLocationChanges()
                } else {
                    locationManager.startUpdatingLocation()
                    locationManager.stopUpdatingLocation()
                }
            }
        }
    }
    
    func start() {
        log("AirportsWatcher start");
        if inSimulator() {
            // startMonitoringSignificantLocationChanges does not work in simulator, see http://stackoverflow.com/a/6213528
            locationManager.startUpdatingLocation()
        } else {
            if useSignificantLocationChanges {
                locationManager.startMonitoringSignificantLocationChanges()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stop() {
        log("AirportsWatcher stop");
        if inSimulator() {
            locationManager.stopUpdatingLocation()
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.stopUpdatingLocation()
        }
    }
    
    func hitTest(latitude:Double, _ longitude:Double) -> [CLCircularRegion] {
        let coord = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        var hits : [CLCircularRegion] = []
        for region in regions {
            if region.containsCoordinate(coord) {
                hits.append(region)
            }
        }
        return hits
    }
    
    func airportPerimeter(region:CLCircularRegion, _ latitude:Double, _ longitude:Double) -> AirportPerimeter {
        func buildInnerRegion(region:CLCircularRegion) -> CLCircularRegion {
            let center = region.center
            let radius = CLLocationDistance(innerAirportPerimeterDistance)
            let id = region.identifier
            let region = CLCircularRegion(center: center, radius: radius, identifier: id)
            return region
        }
        let coord = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        let innerRegion = buildInnerRegion(region)
        if innerRegion.containsCoordinate(coord) {
            return .Inner
        } else {
            return .Outer
        }
    }
        
    func processLocationReport(location: CLLocation, native: Bool = true) {
        if location.coordinate.latitude == lastLatitude && location.coordinate.longitude == lastLongitude {
            return
        }
        
        let age = location.timestamp.timeIntervalSinceNow
        log("location update: \(location.coordinate.latitude), \(location.coordinate.longitude) accuracy=\(location.horizontalAccuracy) age=\(age)")
        
        lastLatitude = location.coordinate.latitude
        lastLongitude = location.coordinate.longitude
        
        if native && overrideLocation>0 {
            log("overrideLocation is effective => bail out")
            return
        }

        mapController?.updateLocation(lastLatitude, lastLongitude)
        
        var regions = hitTest(lastLatitude, lastLongitude)
        
        var newAirportsVisitorState = AirportsVisitorState()
        for region in regions {
            let id = region.identifier.toInt()!
            let perimeter = airportPerimeter(region, lastLatitude, lastLongitude)
            
            newAirportsVisitorState.update(id, perimeter)
        }
        
        delegate?.visitorPotentialChangeInState(newAirportsVisitorState)
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
        log("location updating was paused")
        lastError = "iOS LocationManager:\nLocation updating was paused"
        masterController.refreshApp(AppState.Error)
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        log("location updating was resumed")
        masterController.refreshApp()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        masterController.availabilityMonitor.locationAuthorizationStatusDidChange(status)
    }
}

