import UIKit
import MapKit

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

class MapController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var overlaysDefined = false
    var manualDragging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // London
        let location = CLLocationCoordinate2D(
            latitude: 51.50007773,
            longitude: -0.1246402
        )
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mapController = self
        manualDragging = false
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
            log("started manual dragging")
        }
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

