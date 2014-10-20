import UIKit

let textMomActionString = "TextMom"
let callMomActionString = "CallMom"
let momCategoryString = "MomCategory"

class Executor {
    
    init() {
        registerForNotifications()
        
    }
}

// MARK: Notifications / Actions
extension Executor {
    
    func handleActionWithIdentifier(identifier: String?, _ completionHandler: () -> Void) {
        NSLog("Executor: handleActionWithIdentifier \(identifier)")
        // TODO: implement me
        completionHandler()
    }
}

// MARK: Notifications / Actions
extension Executor {
    
    private func buildCallMomAction() -> UIMutableUserNotificationAction {
        let action = UIMutableUserNotificationAction()
        action.identifier = callMomActionString
        action.destructive = false
        action.title = "Call Mom"
        action.activationMode = .Background
        action.authenticationRequired = true
        return action
    }

    private func buildTextMomAction() -> UIMutableUserNotificationAction {
        let action = UIMutableUserNotificationAction()
        action.identifier = textMomActionString
        action.destructive = false
        action.title = "Text Mom"
        action.activationMode = .Background
        action.authenticationRequired = true
        return action
    }

    private func buildMomNotificationCategory() -> UIUserNotificationCategory {
        let callMomAction = buildCallMomAction()
        let textMomAction = buildTextMomAction()
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = momCategoryString
        category.setActions([callMomAction, textMomAction], forContext: .Minimal)
        category.setActions([callMomAction, textMomAction], forContext: .Default)
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
            NSLog("Executor: scheduleMomNotification - other notification(s) are in flight => bail out")
            return false
        }
        let notification = UILocalNotification()
        notification.category = momCategoryString
        notification.alertBody = "Welcome to \(city). How was your flight? You should let your mom know."
        notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(fireOffset))
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        return true
    }
}

// MARK: BrainDelegate
extension Executor : BrainDelegate {
    
    func remindCallMomFromAirport(city:String, _ airportName:String) {
        NSLog("Executor: remindCallMomFromAirport \(airportName) in \(city)")
        scheduleMomNotification(city, 5) // display in 5 seconds, this is useful for testing
    }
   
}