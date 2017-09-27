//
//  WatchLesson.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 19.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation
import ClockKit

class WatchLesson{
    var hour: Int
    var subject_short: String
    var room: String
    var changed: Bool = false
    
    init(hour: Int, subject_short: String, room: String) {
        self.hour = hour
        self.subject_short = subject_short
        self.room = room
    }
    
    init(number: Int, rawData: [String:Any]) {
        hour = number
        self.subject_short = rawData["subj"] as? String ?? "ERR"
        self.room = rawData["room"] as? String ?? "ERR"
        self.changed = rawData["change"] as? Bool ?? false
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
