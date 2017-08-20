//
//  Watch_Lesson.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 17.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation
import ClockKit

class WatchVPData {
    var days: [Int:WatchDay] = [:]
    
    var intervals: [Int:DateInterval] = [:]
    
    func getTimeForLesson(with number: Int) -> DateInterval? {
        return intervals[number - 1]
    }
    
    
    
    func refreshData(userInfo: [String:Any]) {
        for i in 0...4 {
            if let rawDay = userInfo[String(i)] as? [String:Any]{
                let newDay = WatchDay(number: i, rawData: rawDay)
                days[i] = newDay
            }
        }
        
        if let timeRaw = userInfo["timescheme"] as? [String:Any] {
            for i in 0...9 {
                if let intRaw = timeRaw[String(i)] as? [String:Any] {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let startDate = formatter.date(from: intRaw["from"] as! String), let endDate = formatter.date(from: intRaw["to"] as! String) {
                        
                        let interval = DateInterval(start: startDate, end: endDate)
                        intervals[i] = interval
                    }
                    
                }
            }
        }
        if let c = CLKComplicationServer.sharedInstance().activeComplications?[0]{
            CLKComplicationServer.sharedInstance().reloadTimeline(for: c)
        }
    }
}
