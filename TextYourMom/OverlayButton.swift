import UIKit

class OverlayButton: UIButton {
    @IBInspectable var xlabel: String!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = nil
    }
    
    override func drawRect(rect: CGRect) {
        Assets.drawButton(frame: rect, label: xlabel)
    }
}

