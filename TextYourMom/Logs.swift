import UIKit

struct LogRecord {
    var message : String
    var filePath : String
    var fileLine : Int
    var timestamp: NSTimeInterval
}

protocol LogsModelDelegate {
    func rowAdded()
}

class LogsModel {
    var logs : [LogRecord] = []
    var delegate : LogsModelDelegate?
    
    init() {
    }
    
    func insert(message:String, _ filePath:String, _ fileLine:Int) {
        let now = NSDate().timeIntervalSince1970
        let record = LogRecord(message:message, filePath:filePath, fileLine:fileLine, timestamp:now)
        logs.append(record)
        delegate?.rowAdded()
    }
}
