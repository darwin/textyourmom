import CoreLocation
import UIKit

protocol ServiceAvailabilityMonitorDelegate {
    func serviceDidBecomeAvailable()
    func serviceDidBecomeUnavailable()
}

class ServiceAvailabilityMonitor {
    
    var isBackgroundAppRefreshAvailable: Bool
    var isLocationServicesAuthorized: Bool
    var isLocationServicesEnabled: Bool
    var hasRequiredNotificationSettings: Bool
    
    var isAvailable: Bool
    var delegate: ServiceAvailabilityMonitorDelegate?
    
    init() {
        // checked initially
        isBackgroundAppRefreshAvailable = false
        isLocationServicesAuthorized = false
        isLocationServicesEnabled = false
        hasRequiredNotificationSettings = false
        
        isAvailable = false
        
        // subscribe to settings changes
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "backgroundRefreshStatusDidChange:",
            name: UIApplicationBackgroundRefreshStatusDidChangeNotification,
            object: nil)
    }
    
    // Perform initial service availability checks when the app is launched.
    //
    func checkAvailability() {
        checkIsBackgroundAppRefreshAvailable()
        checkIsLocationServicesAuthorized()
        checkIsLocationServicesEnabled()
        checkIfHasRequiredNotificationSettings()
        updateAvailabilityAndNotifyDelegateIfChanged(false)
    }
    
    // Background App Refresh must be available in order for the app to be launched by the OS in response to a significant
    // location update.
    // https://developer.apple.com/library/ios/documentation/userexperience/conceptual/LocationAwarenessPG/CoreLocation/CoreLocation.html
    //
    // This is a setting that can be changed by the user unless the setting is restricted (eg. by parental controls).
    // Monitoring of changes to this setting are handled by `backgroundRefreshStatusDidChange:`.
    //
    func checkIsBackgroundAppRefreshAvailable() {
        let status = UIApplication.sharedApplication().backgroundRefreshStatus
        log("UIApplication.sharedApplication().backgroundRefreshStatus is \(status.rawValue)")
        isBackgroundAppRefreshAvailable = status == .Available
    }
    
    // Location Services must be authorized for this app by the user.
    //
    // If the user hasn't yet determined whether they want to authorize location services for the app assume that they
    // will. The first time location services are requested by the app the user will be prompted. If they reject the
    // request the authorization status will be changed and the UI will be updated accordingly.
    //
    // This is a setting that can be changed by the user unless the setting is restricted (eg. by parental controls).
    // Changes to this user setting are monitored by the app.
    //
    func checkIsLocationServicesAuthorized(_ status : CLAuthorizationStatus = CLLocationManager.authorizationStatus()) {
        CLLocationManager.authorizationStatus()
        log("CLLocationManager.authorizationStatus() is \(status.rawValue)")
        isLocationServicesAuthorized = status.rawValue == 3 // Swift problem: .AuthorizedAlways is missing
    }
    
    // Location service must be enabled on the device.
    //
    // This is a setting that can be changed by the user. Monitoring of changes to this setting is also handled by
    // `locationAuthorizationStatusDidChange:`.
    //
    func checkIsLocationServicesEnabled() {
        let status = CLLocationManager.locationServicesEnabled()
        log("CLLocationManager.locationServicesEnabled() is \(status)")
        isLocationServicesEnabled = status
    }
    
    func checkIfHasRequiredNotificationSettings() {
        if SINCE_IOS8 {
            let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
            let hasAlert = (settings.types.rawValue & UIUserNotificationType.Alert.rawValue) != 0
            let hasSound = (settings.types.rawValue & UIUserNotificationType.Sound.rawValue) != 0
            hasRequiredNotificationSettings = hasAlert
        } else {
            hasRequiredNotificationSettings = true
        }
    }
    
    func updateAvailabilityAndNotifyDelegateIfChanged(notify: Bool) {
        let isAvailableUpdated =
            isBackgroundAppRefreshAvailable &&
            isLocationServicesAuthorized &&
            isLocationServicesEnabled &&
            hasRequiredNotificationSettings
        let changed = isAvailableUpdated == isAvailable
        isAvailable = isAvailableUpdated
        if changed && notify {
            if isAvailable {
                delegate?.serviceDidBecomeAvailable()
            } else {
                delegate?.serviceDidBecomeAvailable()
            }
        }
    }
    
    func locationAuthorizationStatusDidChange(status: CLAuthorizationStatus) {
        log("Location authorization status changed: \(status)")
        checkIsLocationServicesAuthorized(status)
        updateAvailabilityAndNotifyDelegateIfChanged(true)
    }
    
    func backgroundRefreshStatusDidChange(notification: NSNotification) {
        isBackgroundAppRefreshAvailable = UIApplication.sharedApplication().backgroundRefreshStatus == .Available
        log("Background App Refresh setting changed: \(isBackgroundAppRefreshAvailable)")
        updateAvailabilityAndNotifyDelegateIfChanged(true)
    }
}