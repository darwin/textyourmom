import UIKit

class Executor {
    
    init() {
    }
    
    func setupNotifications() {
        registerForNotifications()
    }
    
    func hasRequiredNotificationSettings() -> Bool {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        let hasAlert = (settings.types.rawValue & UIUserNotificationType.Alert.rawValue) != 0
        let hasSound = (settings.types.rawValue & UIUserNotificationType.Sound.rawValue) != 0
        return hasAlert
    }
}

// MARK: Notifications / Actions
extension Executor {
    
    func handleActionWithIdentifier(identifier: String?, _ completionHandler: () -> Void) {
        log("handleActionWithIdentifier \(identifier)")
        // TODO: implement me
        completionHandler()
    }
}

// MARK: Notifications / Actions
extension Executor {
    
    private func buildMomNotificationCategory() -> UIUserNotificationCategory {
        let category = UIMutableUserNotificationCategory()
        category.identifier = momCategoryString
        return category
    }

    private func registerForNotifications() {
        let requestedTypes = UIUserNotificationType.Alert | .Sound
        let categories = NSSet(object: buildMomNotificationCategory())
        let settingsRequest = UIUserNotificationSettings(forTypes: requestedTypes, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settingsRequest)
    }
    
    func scheduleMomNotification(city:String, _ fireOffset: Float = 5) -> Bool {
        if UIApplication.sharedApplication().scheduledLocalNotifications.count > 0 {
            log("scheduleMomNotification - other notification(s) are in flight => bail out")
            return false
        }
        let notification = UILocalNotification()
        notification.category = momCategoryString
        notification.alertBody = stringWelcomeMessage(city)
        notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(fireOffset))
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return true
    }
}

// MARK: BrainDelegate
extension Executor : BrainDelegate {
    
    func remindCallMomFromAirport(city:String, _ airportName:String) {
        log("remindCallMomFromAirport \(airportName) in \(city)")
        scheduleMomNotification(city, 5) // display in 5 seconds, this is useful for testing
    }
   
}