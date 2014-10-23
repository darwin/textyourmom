import UIKit

protocol BaseViewControllerCanvasDelegate {
    func subviewAdded(subview: UIView)
}

class BaseViewController: UIViewController {
    
    var debugButton : UIButton?
    var canvasView : CanvasView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView = view as? CanvasView
        if canvasView == nil {
            log("!!! set CanvasView in \(self)")
        } else {
            canvasView!.delegate = self
        }
        injectDebugControlsIfRequired()
    }
    
    func debugButton(sender:UIButton!) {
        switchToScreen("Debug")
    }
    
    func injectDebugControlsIfRequired() {
        if debugButton != nil {
            return
        }
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRectMake(0, 20, 100, 20)
        button.backgroundColor = UIColor.magentaColor()
        button.setTitle("DEBUG", forState: UIControlState.Normal)
        button.addTarget(self, action: "debugButton:", forControlEvents: UIControlEvents.TouchUpInside)
        debugButton = button
        view.addSubview(button)
    }
}

extension BaseViewController : BaseViewControllerCanvasDelegate {

    func subviewAdded(subview: UIView) {
        canvasView!.bringSubviewToFront(debugButton!)
    }
}

