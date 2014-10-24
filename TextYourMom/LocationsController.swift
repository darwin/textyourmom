import UIKit

class LocationsController : BaseViewController {
    @IBOutlet weak var locationPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationPicker.selectRow(overrideLocation, inComponent:0, animated:false)
    }
    
    @IBAction func doApply(sender: UIButton) {
        overrideLocation = locationPicker.selectedRowInComponent(0)
        let newDebugLocation = debugLocations[overrideLocation]
        if overrideLocation > 0 {
            log("manual override of location to \(newDebugLocation.description)")
            masterController.airportsWatcher.emitFakeUpdateLocation(newDebugLocation.latitude, newDebugLocation.longitude)
        } else {
            log("stopped overriding location")
        }
        switchToScreen("Debug")
    }
}

extension LocationsController : UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return debugLocations.count
    }
}

extension LocationsController : UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return debugLocations[row].description
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = debugLocations[row].description
        
        var attrString = NSMutableAttributedString(string: text)
        var range = NSMakeRange(0, attrString.length)
        
        attrString.beginEditing()
        attrString.addAttribute(NSForegroundColorAttributeName, value:UIColor.blueColor(), range:range)
        //attrString.addAttribute(NSFontAttributeName, value:UIFont(name: "System", size: 15.0)!, range:range)
        attrString.endEditing()
        
        return attrString
    }
}
