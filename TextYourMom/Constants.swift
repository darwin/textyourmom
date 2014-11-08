import UIKit
import MapKit

let SINCE_IOS8 = isAtLeastIOS8()
let PRIOR_IOS8 = !SINCE_IOS8

let momCategoryString = "MomCategory"
let outerAirportPerimeterDistance : CLLocationDistance = 15*1000 // TODO: read this from settings?
let innerAirportPerimeterDistance : CLLocationDistance = 3*1000 // TODO: read this from settings?
let allowDeferredLocationUpdatesUntilTraveledDistance : CLLocationDistance = 500*1000 // 500km