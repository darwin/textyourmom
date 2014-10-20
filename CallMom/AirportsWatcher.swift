import CoreLocation

protocol AirportsWatcherDelegate {
    func insideRegion(regionIdentifier: String)
    func didEnterRegion(regionIdentifier: String)
    func didExitRegion(regionIdentifier: String)
}

func buildRegionFromAirport(airport: Airport) -> CLRegion {
    let center = CLLocationCoordinate2D(latitude:airport.latitude, longitude:airport.longitude)
    let radius = CLLocationDistance(10*1000) // 10km TODO: read this from settings
    let id =  String(airport.id)
    let region = CLCircularRegion(center: center, radius: radius, identifier: id)
    return region;
}

class AirportsWatcher: NSObject {
    var locationManager: CLLocationManager = CLLocationManager()
    var delegate: AirportsWatcherDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestRequiredAuthorizations() {
//        if (ios8()) {
//            locationManager.requestAlwaysAuthorization()
//        }
    }
    
    func registerAirports(airportsProvider: AirportsProvider) {
        let airports = airportsProvider.airports
        for airport in airports {
            var region = buildRegionFromAirport(airport)
//            NSLog("R \(region)")
        }
    }
    
    func start() {
        NSLog("AirportsWatcher: start");
    }
    
    func stop() {
        NSLog("AirportsWatcher: stop");
    }
}

// MARK: CLLocationManagerDelegate
extension AirportsWatcher : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        NSLog("AirportsWatcher: didStartMonitoringForRegion")
        locationManager.requestStateForRegion(region) // should locationManager be manager?
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion:CLRegion) {
        NSLog("AirportsWatcher: didEnterRegion \(didEnterRegion.identifier)")
        delegate?.didEnterRegion(didEnterRegion.identifier)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion:CLRegion) {
        NSLog("AirportsWatcher: didExitRegion \(didExitRegion.identifier)")
        delegate?.didExitRegion(didExitRegion.identifier)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        NSLog("AirportsWatcher: didDetermineState \(state)");
        
        switch state {
        case .Inside:
            NSLog("AirportsWatcher: didDetermineState CLRegionState.Inside \(region.identifier)");
            delegate?.insideRegion(region.identifier)
        case .Outside:
            NSLog("AirportsWatcher: didDetermineState CLRegionState.Outside");
        case .Unknown:
            NSLog("AirportsWatcher: didDetermineState CLRegionState.Unknown");
        default:
            NSLog("AirportsWatcher: didDetermineState default");
        }
    }
    
}

