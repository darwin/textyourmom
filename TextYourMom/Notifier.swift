import UIKit

class Notifier {
    
    init() {
    }
    
    func setupNotifications() {
        registerForNotifications()
    }
}

// MARK: Notifications / Actions
extension Notifier {
    
    func handleActionWithIdentifier(identifier: String?, _ completionHandler: () -> Void) {
        log("handleActionWithIdentifier \(identifier)")
        // TODO: implement me
        completionHandler()
    }
}

// MARK: Notifications / Actions
extension Notifier {
    
    private func buildMomNotificationCategory() -> UIUserNotificationCategory {
        let category = UIMutableUserNotificationCategory()
        category.identifier = momCategoryString
        return category
    }

    private func registerForNotifications() {
        if SINCE_IOS8 {
            let requestedTypes = UIUserNotificationType.Alert | .Sound | .Badge
            let categories = NSSet(object: buildMomNotificationCategory())
            let settingsRequest = UIUserNotificationSettings(forTypes: requestedTypes, categories: categories)
            UIApplication.sharedApplication().registerUserNotificationSettings(settingsRequest)
        } else {
            // ios7 does not need registration for local notifications
        }
    }
    
    func scheduleMomNotification(city:String, _ fireOffset: Float = 5) -> Bool {
        if UIApplication.sharedApplication().scheduledLocalNotifications.count > 0 {
            log("scheduleMomNotification - other notification(s) are in flight => bail out")
            return false
        }
        let notification = UILocalNotification()
        if SINCE_IOS8 {
            notification.category = momCategoryString
        }
        notification.alertBody = stringWelcomeMessage(city)
        notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(fireOffset))
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return true
    }
}

// MARK: BrainDelegate
extension Notifier : BrainDelegate {
    
    func remindCallMomFromAirport(city:String, _ airportName:String) {
        log("remindCallMomFromAirport \(airportName) in \(city)")
        scheduleMomNotification(city, 5) // display in 5 seconds, this is useful for testing
    }
   
}