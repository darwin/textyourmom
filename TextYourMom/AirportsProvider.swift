import UIKit

class AirportsProvider {
    var airports : [Airport]
    
    init() {
        airports = [];
    }
    
    func lookupAirport(id:Int) -> Airport? {
        return $.find(airports, { $0.id == id })
    }
}

// MARK: parsing the data file
extension AirportsProvider {
    
    func parseFromResource(name:String, type:String="txt") -> Bool {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: type)
        if path == nil {
            log("Error forming path for resource \(name) of type \(type)")
            return false;
        }
        return parseFromFile(path!)
    }

    func parseFromFile(path:String) -> Bool {
        var err: NSError?
        let content = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: &err)
        if content == nil {
            log("\(err)")
            return false;
        }
        
        func parseAirportLine(line: String) -> Airport? {
            func readQuotedString(s: String) -> String {
                // TODO: implement proper unwrapping here
                return s.substringWithRange(Range<String.Index>(start: advance(s.startIndex, 1), end: advance(s.endIndex, -1)))
            }

            func readIntValue(s: String) -> Int {
                if let result = s.toInt() {
                    return result
                } else {
                    return 0;
                }
            }

            func readDoubleValue(s: String) -> Double {
                return (s as NSString).doubleValue
            }
            
            var parts = line.componentsSeparatedByString(",")
            
            // TODO: better error checking here
            var airport = Airport()
            airport.id = readIntValue(parts[0])
            airport.name = readQuotedString(parts[1])
            airport.city = readQuotedString(parts[2])
            airport.country = readQuotedString(parts[3])
            airport.latitude = readDoubleValue(parts[6])
            airport.longitude = readDoubleValue(parts[7])
            
            return airport;
        }

        var counter = 0
        var list = content!.componentsSeparatedByString("\n")
        for line in list {
            if line.isEmpty {
                continue
            }
            counter++
            if let airport = parseAirportLine(line) {
                airports.append(airport)
            } else {
                log("\(line)")
            }
        }
        
        return true
    }
}