import UIKit

var model = Model()
var masterController = MasterController()
var sharedLogsModel = LogsModel()
var mainWindow : UIWindow?
var disableScreenSwitching = false
var presentViewControllerQueue = dispatch_queue_create("presentViewControllerQueue", DISPATCH_QUEUE_SERIAL)
var lastError : String?
var mapController : MapController?
let momCategoryString = "MomCategory"

var overrideLocation = 0 // 0 means no override