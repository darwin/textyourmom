import UIKit
import Foundation

func ios7() -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 7, minorVersion: 0, patchVersion: 0))
}

func ios8() -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0))
}

func ios9() -> Bool {
    return NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0))
}

func inSimulator() -> Bool {
    return UIDevice.currentDevice().model == "iPhone Simulator"
}

func leftPadding(message:String, len: Int, char: String = " ") -> String {
    var result = message
    while countElements(result) < len {
        result = char+result
    }
    return result
}

func rightPadding(message:String, len: Int, char: String = " ") -> String {
    var result = message
    while countElements(result) < len {
        result = result+char
    }
    return result
}

func log(message:String, filePath:String = __FILE__, line: Int = __LINE__, functionName:String = __FUNCTION__) {
    let fileNameWithoutExtension = filePath.lastPathComponent.stringByReplacingOccurrencesOfString(".swift", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    let paddedLine = rightPadding("\(line)", 4)
    let paddedFile = leftPadding("\(fileNameWithoutExtension):\(paddedLine)", 32)
    NSLog("\(paddedFile)  \(message)");
    
    sharedLogsModel.insert(message, filePath, line)
}