struct LogRecord {
    var message : String
    var filePath : String
    var fileLine : Int
}

protocol LogsModelDelegate {
    func refresh()
}

class LogsModel {
    var logs : [LogRecord] = []
    var delegate : LogsModelDelegate?
    
    init() {
    }
    
    func insert(message:String, _ filePath:String, _ fileLine:Int) {
        let record = LogRecord(message:message, filePath:filePath, fileLine:fileLine)
        logs.append(record)
        delegate?.refresh()
    }
}
