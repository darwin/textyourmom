import UIKit

class CanvasView: UIView {
    
    var delegate : BaseViewControllerCanvasDelegate?
    
    override func didAddSubview(subview: UIView) {
        delegate?.subviewAdded(subview)
    }
    
}

