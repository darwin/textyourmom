import UIKit

struct LogRecord {
    var message : String
    var filePath : String
    var fileLine : Int
    var timestamp: NSTimeInterval
}

protocol LogsModelDelegate {
    func rowAdded()
    func refresh()
}

class LogsModel {
    var logs : [LogRecord] = []
    var delegate : LogsModelDelegate?
    var dirty = false
    var timer : NSTimer?
    
    init() {
        
    }
    
    func insert(message:String, _ filePath:String, _ fileLine:Int) {
        let now = NSDate().timeIntervalSince1970
        let record = LogRecord(message:message, filePath:filePath, fileLine:fileLine, timestamp:now)
        logs.append(record)
        dirty = true
        delegate?.rowAdded()
    }
    
    func startSerializationTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("serializationTick"), userInfo: nil, repeats: true)
    }
    
    @objc func serializationTick() {
        if !dirty {
            return
        }
        dirty = false
        model.logs = serialize()
    }
}

// MARK: serialization
extension LogsModel {
    
    var lineSeparator : Character {
        get { return "\u{2603}" }
    }

    var itemSeparator : Character {
        get { return "\u{2604}" }
    }

    func serialize() -> String {
        var lines = [String]()
        for log in logs {
            var parts = [String]()
            parts.append(String(format: "%.1f", log.timestamp))
            parts.append(log.message)
            parts.append(log.filePath)
            parts.append(String(log.fileLine))
            var line = String(itemSeparator).join(parts)
            lines.append(line)
        }
        return String(lineSeparator).join(lines)
    }
    
    func unserialize(data: String) {
        logs.removeAll(keepCapacity: true)
        let lines = split(data) {$0 == self.lineSeparator}
        for line in lines {
            let items = split(line) {$0 == self.itemSeparator}
            if items.count != 4 {
                log("!!! unable to unserialize line: \(line)")
                continue
            }
            
            let timestamp = (items[0] as NSString).doubleValue
            let message = items[1]
            let filePath = items[2]
            let fileLine = items[3].toInt()!
            
            let record = LogRecord(message:message, filePath:filePath, fileLine:fileLine, timestamp:timestamp)
            logs.append(record)
        }
        delegate?.refresh()
    }
}

// MARK: human readable dump
extension LogsModel {

    func dump() -> String {
        let lineSeparator = "\n"
        let itemSeparator = "\t"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "D hh:mm:ss"
        var lines = [String]()
        for log in logs {
            var parts = [String]()
            let time = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970:log.timestamp))
            parts.append(time)
            parts.append(log.message)
            var line = String(itemSeparator).join(parts)
            lines.append(line)
        }
        return String(lineSeparator).join(lines)
    }
}
