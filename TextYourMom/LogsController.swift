import UIKit

class LogItemCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
}

class LogsController: BaseViewController {
    var model : LogsModel = sharedLogsModel
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 20.0;
        model.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func prepareCell() -> LogItemCell {
        return tableView.dequeueReusableCellWithIdentifier("logItem") as LogItemCell
    }

    func configureCell(cell:LogItemCell, row:Int) {
        cell.message.text = model.logs[row].message
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
        return 16
    }
    
}

extension LogsController : UITableViewDelegate {
}

extension LogsController : LogsModelDelegate {

    func refresh() {
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:model.logs.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
}
