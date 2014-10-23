import UIKit

class DebugController: BaseViewController {
    
    @IBAction func doIntroWorkflow(sender: UIButton) {
        masterController.introPlayed = false
        masterController.refreshApp(AppState.Intro)
    }

    @IBAction func doNormalWorkflow(sender: UIButton) {
        masterController.refreshApp(AppState.Normal)
    }

    @IBAction func doErrorWorkflow(sender: UIButton) {
        let message = "This is a sample error message which could span multiple lines\nlet's see\nline1\nline2\nline3\nline4\nline5"
        masterController.refreshApp(AppState.Error(message))
    }

    @IBAction func doResetState(AnyObject) {
        // TODO: reset state
        log("doResetState");
    }
    
    @IBAction func doOverrideLocation(AnyObject) {
        // TODO: set location
        log("doOverrideLocation");
    }
    
    @IBAction func doShowLogs(sender: UIButton) {
        switchToScreen("Logs")
    }
}