import UIKit

class LogItemCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
}

class LogsController: BaseViewController {
    var model : LogsModel = sharedLogsModel
    let dateFormatter = NSDateFormatter()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        dateFormatter.dateFormat = "D hh:mm:ss"
    }

    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func prepareCell() -> LogItemCell {
        return tableView.dequeueReusableCellWithIdentifier("logItem") as LogItemCell
    }

    func configureCell(cell:LogItemCell, row:Int) {
        let data = model.logs[row]
        let time = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970:data.timestamp))
        let msg = data.message

        cell.message.text = "\(time) \(msg)"
    }
    
}

extension LogsController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.logs.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = prepareCell()
        configureCell(cell, row: indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = prepareCell()
        configureCell(cell, row: indexPath.row)
        cell.message.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds)
        let size = cell.message.intrinsicContentSize()
        return size.height + 1
    }
    
}

extension LogsController : UITableViewDelegate {
}

extension LogsController : LogsModelDelegate {

    func rowAdded() {
        let wasScrolledToBottom = tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height

        let path = NSIndexPath(forRow: model.logs.count-1, inSection: 0)
        tableView.insertRowsAtIndexPaths([path], withRowAnimation: .Fade)
        
        if wasScrolledToBottom {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:model.logs.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    func refresh() {
        tableView.reloadData()
    }
}
