import UIKit
import Foundation

extension Int {
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}

func isAtLeastIOS8() -> Bool {
    // http://stackoverflow.com/a/18076628
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1
}

func inSimulator() -> Bool {
    return UIDevice.currentDevice().model == "iPhone Simulator"
}

func isAdHocDistribution() -> Bool {
    // http://stackoverflow.com/a/13995403/84283
    if let path = NSBundle.mainBundle().pathForResource("embedded", ofType:"mobileprovision") {
        // not from app store
        return true
    } else {
        // from app store
        return false
    }
}

func appVersion() -> String {
    return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
}

func appBuild() -> String {
    return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as NSString) as String
}

func versionBuild() -> String {
    let version = appVersion(), build = appBuild()
    
    return version == build ? "v\(version)" : "v\(version)(#\(build))"
}

func wantDebugTooling() -> Bool {
    return inSimulator() || isAdHocDistribution()
}

func leftPadding(message:String, len: Int, char: String = " ") -> String {
    var result = message
    while countElements(result) < len {
        result = char+result
    }
    return result
}

func rightPadding(message:String, len: Int, char: String = " ") -> String {
    var result = message
    while countElements(result) < len {
        result = result+char
    }
    return result
}

func log(message:String, filePath:String = __FILE__, line: Int = __LINE__, functionName:String = __FUNCTION__) {
    let fileNameWithoutExtension = filePath.lastPathComponent.stringByReplacingOccurrencesOfString(".swift", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    let paddedLine = rightPadding("\(line)", 4)
    let paddedFile = leftPadding("\(fileNameWithoutExtension):\(paddedLine)", 32)
    NSLog("\(paddedFile)  \(message)");
    
    sharedLogsModel.insert(message, filePath, line)
}

func storyBoard(name:String? = nil) -> UIStoryboard {
    var effectiveName = name
    if effectiveName == nil {
        effectiveName = "Main" // TODO: lookup this in Info.plist
    }
    return UIStoryboard(name: effectiveName!, bundle: NSBundle.mainBundle())
}

var viewControllerCache = [String: UIViewController]()

func viewController(name:String, storyBoardName:String? = nil) -> UIViewController? {
    if let controller = viewControllerCache[name] {
        return controller
    }
    
    let storyboard = storyBoard(name:storyBoardName)
    var controller = storyboard.instantiateViewControllerWithIdentifier(name) as? UIViewController
    if controller != nil {
//        viewControllerCache[name] = controller
        return controller
    }
    
    log("!!! unable to instantiate UIViewController \(name) from storyboard \(storyBoardName)")
    return nil
}

func topController() -> UIViewController? {
    let rootController = mainWindow?.rootViewController
    if rootController == nil {
        return nil
    }
    
    var controller = rootController!
    while controller.presentedViewController != nil {
        controller = controller.presentedViewController!
    }
    return controller
}

func switchToScreen(name:String, completion: (() -> Void)? = nil) -> UIViewController {
    let controller = viewController(name)!
    if disableScreenSwitching {
        return controller
    }
    queuePresentViewController(controller, false)
    return controller
}

// switchToScreen could be called in reaction to events, potentially multiple times when animations are in-flight
// this is simple queue implementation for serialization of presentViewController calls
// inspiration: https://gist.github.com/kommen/5743831
func queuePresentViewController(to:UIViewController, animated:Bool, completion: (() -> Void)? = nil) {
    dispatch_async(presentViewControllerQueue, {
        var semaphore = dispatch_semaphore_create(0)
        dispatch_async(dispatch_get_main_queue(), {
            var job = { () -> Void in
                dispatch_semaphore_signal(semaphore)
                completion?()
            }
            if let from = topController() {
                if from == to {
                    job()
                } else {
                    from.presentViewController(to, animated:animated, completion:{
                        job()
                    })
                }
            } else {
                log("!!! failed to retrieve top controller")
                job()
            }
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    })
}

var presentViewControllerQueueSemaphore : dispatch_semaphore_t?

func pausePresentViewControllerHelper() -> dispatch_semaphore_t {
    var semaphore = dispatch_semaphore_create(0)
    dispatch_async(presentViewControllerQueue, {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return
    })
    return semaphore
}

func unpausePresentViewControllerHelper(semaphore:dispatch_semaphore_t) {
    dispatch_semaphore_signal(semaphore)
}

func pausePresentViewController() {
    log("pause UI")
    if presentViewControllerQueueSemaphore != nil {
        log("!!! presentViewControllerQueueSemaphore was not nil prior pausePresentViewController call")
    }
    presentViewControllerQueueSemaphore = pausePresentViewControllerHelper()
}

func unpausePresentViewController() {
    log("unpause UI")
    if presentViewControllerQueueSemaphore == nil {
        log("!!! presentViewControllerQueueSemaphore was nil prior unpausePresentViewController call")
    }
    unpausePresentViewControllerHelper(presentViewControllerQueueSemaphore!)
}


