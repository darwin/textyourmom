import UIKit
import MapKit

struct DebugLocation {
    var description : String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(_ description: String, _ latitude: Double, _ longitude: Double) {
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
    }
}


let debugLocations = [
    DebugLocation("DONT OVERRIDE", 0.0, 0.0), // #0
    DebugLocation("x no-mans-land", 48, 14),
    DebugLocation("x surf office Las Palmas",28.1286,-15.4452),
    DebugLocation("x surf office Santa Cruz",36.9624,-122.0310),
    DebugLocation("SFO-inner-Milbrae-inner",37.6145,-122.3776),
    DebugLocation("SFO-outer-Milbrae-outer",37.6231,-122.4166),
    DebugLocation("SFO-outer-Milbrae-inner",37.6008,-122.4067),
    DebugLocation("SFO-inner-Milbrae-outer",37.6356,-122.3677),
    DebugLocation("SFO-outer",37.6547,-122.3687),
    DebugLocation("Milbrae-outer",37.5679,-122.3944),
    DebugLocation("Ceske Budejovice",48.946381,14.427464),
    DebugLocation("Caslav",49.939653,15.381808),
    DebugLocation("Hradec Kralove",50.2532,15.845228),
    DebugLocation("Horovice",49.848111,13.893506),
    DebugLocation("Kbely",50.121367,14.543642),
    DebugLocation("Kunovice",49.029444,17.439722),
    DebugLocation("Karlovy Vary",50.202978,12.914983),
    DebugLocation("Plzen Line",49.675172,13.274617)
]

class AirportOverlay: MKCircle {
    var type : AirportPerimeter = .Inner
    
    func setupRenderer(renderer: MKCircleRenderer) {
        let innerColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.05)
        let outerColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        if type == .Inner {
            renderer.fillColor = innerColor
            renderer.strokeColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
            renderer.lineWidth = 1
        } else {
            renderer.fillColor = outerColor
        }
    }
}

class FakeLocationAnnotation : MKPointAnnotation {
    
}

class CenterLocationAnnotation : MKPointAnnotation {
    
}

class MapController: BaseViewController {
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerLabel: UILabel!
    var overlaysDefined = false
    var manualDragging = false
    var fakeLocationAnnotation = FakeLocationAnnotation()
    var centerLocationAnnotation = CenterLocationAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationPicker.selectRow(overrideLocation, inComponent:0, animated:false)

        // this is here just to prevent slow map loading because of extreme zoom-out
        let londonLocation = CLLocationCoordinate2D(
            latitude: 51.50007773,
            longitude: -0.1246402
        )
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: londonLocation, span: span)
        mapView.setRegion(region, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mapController = self
        manualDragging = false
        mapView.removeAnnotation(centerLocationAnnotation)
        defineAirportOverlays(masterController.airportsProvider)
    }

    override func viewDidDisappear(animated: Bool) {
        mapController = nil
        super.viewDidDisappear(animated)
    }

    func defineAirportOverlays(provider:AirportsProvider) {
        if overlaysDefined {
            return
        }
        
        func buildAirportOverlay(airport: Airport, perimeter: AirportPerimeter) -> AirportOverlay {
            let center = CLLocationCoordinate2D(latitude:airport.latitude, longitude:airport.longitude)
            let radius = CLLocationDistance(perimeter==AirportPerimeter.Inner ? innerAirportPerimeterDistance : outerAirportPerimeterDistance)
            var overlay = AirportOverlay(centerCoordinate: center, radius: radius)
            overlay.type = perimeter
            return overlay
        }
        
        let airports = provider.airports
        var overlays : [AirportOverlay] = []
        var annotations : [MKPointAnnotation] = []
        for airport in airports {
            overlays.append(buildAirportOverlay(airport, .Outer))
            overlays.append(buildAirportOverlay(airport, .Inner))
            
            let annotation = MKPointAnnotation()
            annotation.setCoordinate(CLLocationCoordinate2D(latitude:airport.latitude, longitude:airport.longitude))
            annotation.title = airport.name
            annotations.append(annotation)
        }
        mapView.addOverlays(overlays)
        mapView.addAnnotations(annotations)
        overlaysDefined = true
    }

    func updateLocation(latitude: Double, _ longitude:Double) {
        if manualDragging {
            return
        }
        let location = CLLocationCoordinate2D(latitude: latitude, longitude:longitude)
        mapView.setCenterCoordinate(location, animated: true)
    }

    @IBAction func doApplyLocationOverride() {
        manualDragging = false
        mapView.removeAnnotation(centerLocationAnnotation)
        overrideLocation = locationPicker.selectedRowInComponent(0)
        let newDebugLocation = debugLocations[overrideLocation]
        if overrideLocation > 0 {
            log("manual override of location to \(newDebugLocation.description)")
            masterController.airportsWatcher.emitFakeUpdateLocation(newDebugLocation.latitude, newDebugLocation.longitude)
            fakeLocationAnnotation.setCoordinate(CLLocationCoordinate2D(latitude:newDebugLocation.latitude, longitude:newDebugLocation.longitude))
            mapView.addAnnotation(fakeLocationAnnotation)
        } else {
            log("stopped overriding location")
            mapView.removeAnnotation(fakeLocationAnnotation)
        }
    }
}

// MARK: MKMapViewDelegate
extension MapController : MKMapViewDelegate{
    
    // http://stackoverflow.com/a/26002176/84283
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = (mapView.subviews[0] as? UIView)
        let recognizers = view!.gestureRecognizers! as [AnyObject]
        for recognizer in recognizers {
            if recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended {
                return true;
            }
        }
        return false
    }
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            manualDragging = true
            mapView.addAnnotation(centerLocationAnnotation)
            log("started manual dragging")
        }
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        var center = mapView.centerCoordinate
        centerLocationAnnotation.setCoordinate(center)
        let fmt = ".4"
        centerLabel.text = "\(center.latitude.format(fmt)), \(center.longitude.format(fmt))"
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let airportOverlay = overlay as? AirportOverlay {
            var circleRenderer = MKCircleRenderer(overlay: airportOverlay)
            airportOverlay.setupRenderer(circleRenderer)
            return circleRenderer
        }
        return nil
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil // map view should draw "blue dot" for user location
        }
        
        if annotation is FakeLocationAnnotation {
            let reuseId = "fake-location"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "Crosshairs")
                annotationView.centerOffset = CGPointMake(0, 0)
                annotationView.calloutOffset = CGPointMake(0, 0)
            }
            annotationView.annotation = annotation
            return annotationView
        }

        if annotation is CenterLocationAnnotation {
            let reuseId = "center-location"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView.canShowCallout = false
                annotationView.image = UIImage(named: "MagentaDot")
                annotationView.centerOffset = CGPointMake(0, 0)
                annotationView.calloutOffset = CGPointMake(0, 0)
            }
            annotationView.annotation = annotation
            return annotationView
        }

        let reuseId = "airport"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "DotCircle")
            annotationView.centerOffset = CGPointMake(0, 0)
            annotationView.calloutOffset = CGPointMake(0, 0)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}

extension MapController : UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return debugLocations.count
    }
}

extension MapController : UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return debugLocations[row].description
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = debugLocations[row].description
        
        var attrString = NSMutableAttributedString(string: text)
        var range = NSMakeRange(0, attrString.length)
        
        attrString.beginEditing()
        attrString.addAttribute(NSForegroundColorAttributeName, value:UIColor.blueColor(), range:range)
        attrString.endEditing()
        
        return attrString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        doApplyLocationOverride()
    }
}


