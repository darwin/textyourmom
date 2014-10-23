import UIKit

class DebugController: BaseViewController {
    
    @IBAction func doResetState(AnyObject) {
        log("doResetState");
    }

    @IBAction func doSetLocation(AnyObject) {
        log("doSetLocation");
    }

    @IBAction func doShowLogs(sender: UIButton) {
        switchToScreen("Logs")
    }
}