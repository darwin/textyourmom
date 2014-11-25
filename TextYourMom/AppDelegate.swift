import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
}

// MARK: UIApplicationDelegate / Life Cycle
extension AppDelegate : UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // we assume application was launched by user with UI
        // at this point supressNextStateChangeReport is set to true
        // it means we don't want to report airport visit immediatelly after normal app launch
        // see *** below for special case
        supressNextStateChangeReport = true
        
        pausePresentViewController()
        if inSimulator() {
            log("running in simulator")
        }
        let device = UIDevice.currentDevice()
        log("device: \(device.systemName) \(device.systemVersion) [\(device.model)]")
        mainWindow = window
        masterController.boot()
        
        // we could be launched on background, refreshApp() is needed in this case because UI never comes up
        if let options = launchOptions {
            log("launchOptions: \(launchOptions)")
            if let key: AnyObject = options[UIApplicationLaunchOptionsLocalNotificationKey] {
                // we are launched in reaction to location change notification (in the background without UI)
                // *** in this special case we want to report potential state change because we just continue
                // from previous state
                supressNextStateChangeReport = false
            }
        }
        
        masterController.refreshApp()

        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        log("applicationWillResignActive")
        disableScreenSwitching = true
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        log("applicationDidEnterBackground")
        model.save("applicationDidEnterBackground")
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
        masterController.tearDown()
    }
    
}

// MARK: UIApplicationDelegate / Notifications
extension AppDelegate : UIApplicationDelegate {
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        log("didReceiveLocalNotification")
        if application.applicationState == .Active {
            // TODO: how to handle notification when active?
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification,
completionHandler: () -> Void) {
        log("handleActionWithIdentifier #\(identifier)")
        masterController.notifier.handleActionWithIdentifier(identifier, completionHandler)
    }
    
}