import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    var airportsProvider = AirportsProvider()
    var airportsWatcher = AirportsWatcher()
    var brain = Brain()
    var executor = Executor()

}

// MARK: UIApplicationDelegate / Life Cycle
extension AppDelegate : UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        brain.delegate = executor // executor will resond to brain decisions
        NSLog("AppDelegate: Parsing airports...")
        airportsProvider.parseFromResource("airports")
        NSLog("AppDelegate: Adding airports into airports watcher...")
        airportsWatcher.delegate = self
        airportsWatcher.registerAirports(airportsProvider)
        NSLog("AppDelegate: Starting app...")
        if !airportsWatcher.start() {
            NSLog("AppDelegate: airportsWatcher failed to start")
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSLog("AppDelegate: applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSLog("AppDelegate: applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSLog("AppDelegate: applicationWillEnterForeground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        NSLog("AppDelegate: applicationDidBecomeActive")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        NSLog("AppDelegate: applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

// MARK: UIApplicationDelegate / Notifications
extension AppDelegate : UIApplicationDelegate {
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSLog("AppDelegate: didReceiveLocalNotification #\(notification)")
        if application.applicationState == .Active {
            // TODO: how to handle notification when active?
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification,
completionHandler: () -> Void) {
        NSLog("AppDelegate: handleActionWithIdentifier #\(identifier)")
        executor.handleActionWithIdentifier(identifier, completionHandler)
    }
    
}

// MARK: AirportsWatcherDelegate
extension AppDelegate : AirportsWatcherDelegate {

    func enteredAirport(airportId:Int) {
        NSLog("AppDelegate: enteredAirport #\(airportId)")
        if let airport = airportsProvider.lookupAirport(airportId) {
            brain.enteredAiport(airport.city, airport.name)
        } else {
            // TODO: DCHECK
        }
    }
    
    func enteredNoMansLand() {
        NSLog("AppDelegate: enteredNoMansLand")
    }

}