import UIKit

struct DebugLocation {
    var description : String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(_ description: String, _ latitude: Double, _ longitude: Double) {
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
    }
}


let debugLocations = [
    DebugLocation("DONT OVERRIDE", 0.0, 0.0), // #0
    DebugLocation("no-mans-land",100000, 0),
    DebugLocation("Ceske Budejovice",48.946381,14.427464),
    DebugLocation("Caslav",49.939653,15.381808),
    DebugLocation("Hradec Kralove",50.2532,15.845228),
    DebugLocation("Horovice",49.848111,13.893506),
    DebugLocation("Kbely",50.121367,14.543642),
    DebugLocation("Kunovice",49.029444,17.439722),
    DebugLocation("Karlovy Vary",50.202978,12.914983),
    DebugLocation("Plzen Line",49.675172,13.274617)
]

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
