//
//  ComplicationController.swift
//  Vertretungsplan_Watch Extension
//
//  Created by Tim Grohmann on 17.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import ClockKit
import WatchKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward,.backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        var modularTemplate: CLKComplicationTemplate?
        
        let date = Date()
        
        /* Use this for testing a specific date
         
        let intFormatter = DateFormatter()
        intFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let date = intFormatter.date(from: "21.08.2017 7:00")!*/
        
        let weekday = Calendar.current.component(.weekday, from: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let str = formatter.string(from: date)
        let timeDate = formatter.date(from: str)!
        
        let lessonsToday = data.days[weekday - 2]?.lessons ?? []
        for lesson in lessonsToday {
            let time = data.getTimeForLesson(with: lesson.hour)
            if (time?.contains(timeDate) ?? false){
                modularTemplate = lesson.timeLineTemplate
                break
            }
            if let timePrevious = data.getTimeForLesson(with: lesson.hour - 1)?.end, let timeStart = time?.start {
                let timeInbetween = DateInterval(start: timePrevious, end: timeStart)
                if timeInbetween.contains(timeDate){
                    modularTemplate = lesson.timeLineTemplate
                }
            }
        }
        
        if let first = lessonsToday.first, let time = data.getTimeForLesson(with: first.hour) {
            if timeDate < time.start {
                modularTemplate = first.timeLineTemplate
            }
        }
        
        if modularTemplate == nil {
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "---")
            template.line2TextProvider = CLKSimpleTextProvider(text: "---")
            modularTemplate = template
        }
        
        let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: modularTemplate!)
        print("current timelineEntry added")
        handler(timelineEntry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        
        var entries: [CLKComplicationTimelineEntry] = []
        
        let date = Date()
        let weekday = Calendar.current.component(.weekday, from: date)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let str = formatter.string(from: date)
        let timeDate = formatter.date(from: str)!
        
        
        let weekDayData = data.days[weekday - 2]
        //let weekDayData = data.days[0]
        
        
        let lessonsToday = weekDayData?.lessons ?? []
        for lesson in lessonsToday {
            let time = data.getTimeForLesson(with: lesson.hour)
            
            if (time?.start)! > timeDate {
                continue
            }
            
            let start = time!.start
            
            let startMinute = Calendar.current.component(.minute, from: start)
            let startHour = Calendar.current.component(.hour, from: start)
            
            let startDate = Calendar.current.date(bySettingHour: startHour, minute: startMinute, second: 0, of: Date())
            
            let modularTemplate = lesson.timeLineTemplate
            let entry = CLKComplicationTimelineEntry(date: startDate!, complicationTemplate: modularTemplate)
            
            entries.append(entry)
            
            if let timeNext = data.getTimeForLesson(with: lesson.hour + 1)?.start, let timeEnd = time?.end {
                let timeInbetween = DateInterval(start: timeEnd, end: timeNext)
                if timeInbetween.duration > 60 {
                    let emptyTemplate = CLKComplicationTemplateModularSmallStackText()
                    emptyTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
                    emptyTemplate.line2TextProvider = CLKSimpleTextProvider(text: "---")
                    
                    
                    if let emptyStartDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: timeEnd), minute: Calendar.current.component(.minute, from: timeEnd), second: 0, of: Date()){
                        let entry = CLKComplicationTimelineEntry(date: emptyStartDate, complicationTemplate: emptyTemplate)
                        entries.append(entry)
                    }
                }
            }
            
        }
        
        if let lastLesson = lessonsToday.last {
            let lastTimeInterval = data.getTimeForLesson(with: lastLesson.hour)
            if let endOfDay = lastTimeInterval?.end {
                let modularTemplate = CLKComplicationTemplateModularSmallStackText()
                modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
                modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: "---")
                
                
                let endStartMinute = Calendar.current.component(.minute, from: endOfDay)
                let endStartHour = Calendar.current.component(.hour, from: endOfDay)
                if let endStartDate = Calendar.current.date(bySettingHour: endStartHour, minute: endStartMinute, second: 0, of: Date()){
                    let entry = CLKComplicationTimelineEntry(date: endStartDate, complicationTemplate: modularTemplate)
                    entries.append(entry)
                }
            }
        }
        
        
        // Call the handler with the timeline entries prior to the given date
        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries: [CLKComplicationTimelineEntry] = []
        
        let date = Date()
        let weekday = Calendar.current.component(.weekday, from: date)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let str = formatter.string(from: date)
        let timeDate = formatter.date(from: str)!
        
        
        let weekDayData = data.days[weekday - 2]
        //let weekDayData = data.days[0]
        
        let lessonsToday = weekDayData?.lessons ?? []
        for lesson in lessonsToday {
            let time = data.getTimeForLesson(with: lesson.hour)
            
            if (time?.start)! < timeDate {
                continue
            }
            
            let start = time!.start
            
            let startMinute = Calendar.current.component(.minute, from: start)
            let startHour = Calendar.current.component(.hour, from: start)
            
            let startDate = Calendar.current.date(bySettingHour: startHour, minute: startMinute, second: 0, of: Date())
            
            let modularTemplate = CLKComplicationTemplateModularSmallStackText()
            
            print(lesson,"added to Time Travel")
            
            modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: lesson.subject_short.uppercased())
            modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: lesson.room.uppercased())
            let entry = CLKComplicationTimelineEntry(date: startDate!, complicationTemplate: modularTemplate)
            entries.append(entry)
            
            if let timeNext = data.getTimeForLesson(with: lesson.hour + 1)?.start, let timeEnd = time?.end {
                let timeInbetween = DateInterval(start: timeEnd, end: timeNext)
                if timeInbetween.duration > 60 {
                    let emptyTemplate = CLKComplicationTemplateModularSmallStackText()
                    emptyTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
                    emptyTemplate.line2TextProvider = CLKSimpleTextProvider(text: "---")
                    
                    
                    if let emptyStartDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: timeEnd), minute: Calendar.current.component(.minute, from: timeEnd), second: 0, of: Date()){
                        let entry = CLKComplicationTimelineEntry(date: emptyStartDate, complicationTemplate: emptyTemplate)
                        entries.append(entry)
                    }
                }
            }
            
        }
        
        if let lastLesson = lessonsToday.last {
            let lastTimeInterval = data.getTimeForLesson(with: lastLesson.hour)
            if let endOfDay = lastTimeInterval?.end {
                let modularTemplate = CLKComplicationTemplateModularSmallStackText()
                modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
                modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: "---")
                let entry = CLKComplicationTimelineEntry(date: endOfDay, complicationTemplate: modularTemplate)
                entries.append(entry)
            }
        }
        
        
        // Call the handler with the timeline entries prior to the given date
        //handler(entries)
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let modularTemplate = CLKComplicationTemplateModularSmallStackText()
        modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "DEU")
        modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: "S206")
        handler(modularTemplate)
    }
    
    
    var data: WatchVPData {
        return (WKExtension.shared().delegate as! ExtensionDelegate).currentData
    }
    
}
