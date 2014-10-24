import UIKit

class DebugController: BaseViewController {
    
    @IBAction func doIntroWorkflow(sender: UIButton) {
        model.introPlayed = false
        masterController.refreshApp(AppState.Intro)
    }

    @IBAction func doNormalWorkflow(sender: UIButton) {
        masterController.refreshApp(AppState.Normal)
    }

    @IBAction func doErrorWorkflow(sender: UIButton) {
        lastError = stringSampleError()
        masterController.refreshApp(AppState.Error)
    }

    @IBAction func doResetState(sender: UIButton) {
        masterController.tearDown()
        model.reset()
        masterController.boot()
        masterController.refreshApp()
    }
    
    @IBAction func doOverrideLocation(sender: UIButton) {
        switchToScreen("Locations")
    }
    
    @IBAction func doShowLogs(sender: UIButton) {
        switchToScreen("Logs")
    }
    
    @IBAction func doPrintMode(sender: UIButton) {
        model.debugPrint()
    }

    @IBAction func doShowMap(sender: UIButton) {
        switchToScreen("Map")
    }
}