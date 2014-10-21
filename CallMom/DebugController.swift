import UIKit

class DebugController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doResetState(AnyObject) {
        log("doResetState");
    }

    @IBAction func doSetLocation(AnyObject) {
        log("doSetLocation");
    }

}

