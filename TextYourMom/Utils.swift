import UIKit
import Foundation

func ios7() -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 7, minorVersion: 0, patchVersion: 0))
}

func ios8() -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0))
}

func ios9() -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0))
}

func inSimulator() -> Bool {
    return UIDevice.currentDevice().model == "iPhone Simulator"
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

func viewController(name:String, storyBoardName:String? = nil) -> UIViewController? {
    let storyboard = storyBoard(name:storyBoardName)
    return storyboard.instantiateViewControllerWithIdentifier(name) as? UIViewController
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

var disableScreenSwitching = false

func switchToScreen(name:String, completion: (() -> Void)? = nil) -> UIViewController {
    let controller = viewController(name)!
    if disableScreenSwitching {
        log("-x-> \(name)")
        return controller
    }
    log("---> \(name)")
    queuePresentViewController(controller, false)
    return controller
}

// switchToScreen could be called in reaction to events, potentially multiple times when animations are in-flight
// this is simple queue implementation for serialization of presentViewController calls
// inspiration: https://gist.github.com/kommen/5743831
var presentViewControllerQueue = dispatch_queue_create("presentViewControllerQueue", DISPATCH_QUEUE_SERIAL)
func queuePresentViewController(to:UIViewController, animated:Bool, completion: (() -> Void)? = nil) {
    dispatch_async(presentViewControllerQueue, {
        var sema = dispatch_semaphore_create(0)
        dispatch_async(dispatch_get_main_queue(), {
            if let from = topController() {
                from.presentViewController(to, animated:animated, completion:{
                    dispatch_semaphore_signal(sema);
                    completion?()
                })
            } else {
                log("failed to retrieve top controller")
                dispatch_semaphore_signal(sema);
            }
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}