import MessageUI
import UIKit

protocol BaseViewControllerCanvasDelegate {
    func subviewAdded(subview: UIView)
}

class BaseViewController: UIViewController {
    typealias InitLambda = ((UIViewController) -> Void)
    
    var debugButton : UIButton?
    var feedbackButton : UIButton?
    var canvasView : CanvasView?
    var initializers : [InitLambda] = []

    var mailController = MFMailComposeViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView = view as? CanvasView
        if canvasView == nil {
            log("!!! set CanvasView in \(self)")
        } else {
            canvasView!.delegate = self
        }
        injectDebugControlsIfRequired()
        injectFeedbackControlsIfRequired()
        
        // execute registered initializers
        for initializer in initializers {
           initializer(self)
        }
        initializers = []
    }
    
    func debugButton(sender:UIButton!) {
        switchToScreen("Debug")
    }
    
    func injectDebugControlsIfRequired() {
        if !wantDebugTooling() {
            return
        }
        if debugButton != nil {
            return
        }
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.frame = CGRectMake(0, 20, 100, 20)
        button.backgroundColor = UIColor.magentaColor()
        button.setTitle("DEBUG", forState: UIControlState.Normal)
        button.addTarget(self, action: "debugButton:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)

        debugButton = button
    }

    func feedbackButton(sender:UIButton!) {
        prepareFeedbackEmail()
    }

    func injectFeedbackControlsIfRequired() {
        if feedbackButton != nil {
            return
        }
        
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(CGRectGetWidth(canvasView!.frame)-40-20, 20, 40, 40)
        button.addTarget(self, action: "feedbackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        button.setBackgroundImage(UIImage(named: "PaperPlane"), forState: UIControlState.Normal)
        button.alpha = 0.3
        view.addSubview(button)
        
        feedbackButton = button
    }

    func prepareFeedbackEmail() {
        var emailTitle = stringFeedbackEmailTitle()
        var messageBody = stringFeedbackEmailBody()
        var recipents = [stringFeedbackEmailRecipient()]
        
        mailController.mailComposeDelegate = self
        mailController.setSubject(emailTitle)
        mailController.setMessageBody(messageBody, isHTML: false)
        mailController.setToRecipients(recipents)
        
        let logsDump = sharedLogsModel.dump()
        let logsData = logsDump.dataUsingEncoding(NSUTF8StringEncoding)
        mailController.addAttachmentData(logsData, mimeType:"text/plain", fileName:"logs.txt")
        
        queuePresentViewController(mailController, false)
    }
}

extension BaseViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        switch result.value {
        case MFMailComposeResultCancelled.value:
            log("Mail cancelled")
        case MFMailComposeResultSaved.value:
            log("Mail saved")
        case MFMailComposeResultSent.value:
            log("Mail sent")
        case MFMailComposeResultFailed.value:
            log("Mail sent failure: \(error.localizedDescription)")
        default:
            break
        }
        masterController.refreshApp()
    }
}

extension BaseViewController : BaseViewControllerCanvasDelegate {

    func subviewAdded(subview: UIView) {
        if debugButton != nil {
            canvasView!.bringSubviewToFront(debugButton!)
        }
        
        if feedbackButton != nil {
            canvasView!.bringSubviewToFront(feedbackButton!)
        }
    }
}