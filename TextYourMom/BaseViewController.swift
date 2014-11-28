import MessageUI
import UIKit

protocol BaseViewControllerCanvasDelegate {
    func subviewAdded(subview: UIView)
}

class BaseViewController: UIViewController {
    typealias InitLambda = ((UIViewController) -> Void)
    
    var feedbackButton : UIButton?
    var canvasView : CanvasView?
    var initializers : [InitLambda] = []

    var mailController = MFMailComposeViewController()
    var feedbackButtonTouchDownDate = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView = view as? CanvasView
        if canvasView == nil {
            log("!!! set CanvasView in \(self)")
        } else {
            canvasView!.delegate = self
        }
        injectFeedbackControlsIfRequired()
        
        // execute registered initializers
        for initializer in initializers {
           initializer(self)
        }
        initializers = []
    }
    
    func touchDown(sender:UIButton!) {
        feedbackButtonTouchDownDate = NSDate()
    }

    func touchUp(sender:UIButton!) {
        var timeInterval = abs(feedbackButtonTouchDownDate.timeIntervalSinceNow)
        
        // more than 3 seconds press should opend a debug screen instead of feedback email template
        if timeInterval < 3 {
            prepareFeedbackEmail()
        } else {
            switchToScreen("Debug")
        }
    }

    func injectFeedbackControlsIfRequired() {
        if feedbackButton != nil {
            return
        }
        
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(CGRectGetWidth(canvasView!.frame)-40-20, 20, 40, 40)
        button.addTarget(self, action:"touchUp:", forControlEvents:UIControlEvents.TouchUpInside)
        button.addTarget(self, action:"touchDown:", forControlEvents:UIControlEvents.TouchDown)
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
        if feedbackButton != nil {
            canvasView!.bringSubviewToFront(feedbackButton!)
        }
    }
}