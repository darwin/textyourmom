import UIKit

// EmptyController is set as initial scene in our default Storyboard
class EmptyController: BaseViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        log("EmptyController.viewDidAppear => unpausePresentViewController")
        unpausePresentViewController()
    }}