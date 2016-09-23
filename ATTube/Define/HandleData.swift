//
//  HandleData.swift
//  ATTube
//
//  Created by Asiantech1 on 8/11/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation

// Hanlde retrived data from server

private extension String {
    static let Hour = "H"
    static let Minute = "M"
    static let Second = "S"
}

class HandleData {

    static func duration(time: String?) -> String {
        var result = ""
        if let time = time {
            var timeString = (time as NSString).substringFromIndex(2)
            var items: [String] = []

            if timeString.rangeOfString(.Hour) != nil {
                items = timeString.componentsSeparatedByString(.Hour)
                result += items.first!
                timeString = items.last!
            }

            if timeString.rangeOfString(.Minute) == nil {
                result += result.length == 0 ? "0" : ":00"
            } else {
                items = timeString.componentsSeparatedByString(.Minute)
                result += result.length == 0 ? items.first! : (":" + (items.first!.length == 1 ? ("0" + items.first!) : items.first!))
                timeString = items.last!
            }

            if timeString.rangeOfString(.Second) == nil {
                result += ":00"
            } else {
                items = timeString.componentsSeparatedByString(.Second)
                result += items.first!.length == 1 ? ":0\(items.first!)" : ":\(items.first!)"
            }
        }
        return result
    }

    static func viewCount(viewCountString: String?) -> String {
        if let viewCountString = viewCountString {
            guard let viewCount = Int(viewCountString) else {
                return ""
            }
            if viewCount > 999999 {
                return (viewCountString as NSString).substringToIndex(viewCountString.length - 6) + "M Views"
            } else if viewCount > 999 {
                return (viewCountString as NSString).substringToIndex(viewCountString.length - 3) + "K Views"
            } else {
                return viewCountString
            }
        }
        return ""
    }
}

class HandleTime {
    static func convertIntervalTime(timeInterval: Int) -> (hour: Int, minute: Int, second: Int) {
        let hour = Int(timeInterval / 3600)
        let minute = Int((timeInterval - (hour * 3600)) / 60)
        let second = Int((timeInterval - (hour * 3600)) - (minute * 60))
        return (hour, minute, second)
    }

}
