import UIKit

class OverlayButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if !wantDebugTooling() {
            backgroundColor = nil
        }
    }
}

