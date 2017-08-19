//
//  Watch_Lesson.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 17.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation
import ClockKit

class WatchLesson{
    var hour: Int
    var subject_short: String
    var room: String
    
    init(hour: Int, subject_short: String, room: String) {
        self.hour = hour
        self.subject_short = subject_short
        self.room = room
    }
    
    init(number: Int, rawData: [String:Any]) {
        hour = number
        self.subject_short = rawData["subj"] as? String ?? "ERR"
        self.room = rawData["room"] as? String ?? "ERR"
    }
    
    var timeLineTemplate: CLKComplicationTemplate {
        let modularTemplate = CLKComplicationTemplateModularSmallStackText()
        modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: self.subject_short.uppercased())
        modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: self.room.uppercased())
        return modularTemplate
    }
    
    var futureTimeLineTemplate: CLKComplicationTemplate {
        let modularTemplate = CLKComplicationTemplateModularSmallStackText()
        modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: String(hour) + " " + self.subject_short.uppercased())
        modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: self.room.uppercased())
        return modularTemplate
    }
}

struct WatchDay{
    var dayNumber: Int
    var lessons: [WatchLesson] = []
    
    init(number: Int, rawData: [String:Any]){
        dayNumber = number
        for i in 1...10 {
            if let lessonRaw = rawData[String(i)] as? [String:Any] {
                let lesson = WatchLesson(number: i, rawData: lessonRaw)
                lessons.append(lesson)
            }
        }
    }
}

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
