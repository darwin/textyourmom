import UIKit

var masterController = MasterController()
var mainWindow : UIWindow?

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    var controller = masterController
}

// MARK: UIApplicationDelegate / Life Cycle
extension AppDelegate : UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mainWindow = window
        mainWindow?.makeKeyAndVisible()
        return controller.boot()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        log("applicationWillResignActive")
        disableScreenSwitching = true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        log("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        log("applicationWillEnterForeground")
        masterController.refreshApp()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        log("applicationDidBecomeActive")
        disableScreenSwitching = false
        masterController.refreshApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        log("applicationWillTerminate")
    }
    
}

// MARK: UIApplicationDelegate / Notifications
extension AppDelegate : UIApplicationDelegate {
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        log("didReceiveLocalNotification #\(notification)")
        if application.applicationState == .Active {
            // TODO: how to handle notification when active?
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification,
completionHandler: () -> Void) {
        log("handleActionWithIdentifier #\(identifier)")
        controller.executor.handleActionWithIdentifier(identifier, completionHandler)
    }
    
}