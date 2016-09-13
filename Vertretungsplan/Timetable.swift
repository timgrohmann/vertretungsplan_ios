//
//  Timetable.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 14.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Timetable{
    var days: [Day]
    var numberOfDays: Int{
        return days.count
    }
    
    init(){
        
        let daysFetch: NSFetchRequest<Day> = NSFetchRequest(entityName: "Day")
        
        do {
            days = try managedObjectContext.fetch(daysFetch)
        } catch {
            fatalError("Failed to fetch days: \(error)")
        }
        
        if days.count == 0 {
            print("No days-->add days")
            
            let entity = NSEntityDescription.entity(forEntityName: "Day", in: managedObjectContext)
            
            for i in 0..<5{
                let d = Day(entity: entity!, insertInto: managedObjectContext)
                d.number = i
            }
            
        }
        
        delegate.saveContext()
        
        do {
            days = try managedObjectContext.fetch(daysFetch)
        } catch {
            fatalError("Failed to fetch days: \(error)")
        }
        
        for day in days{
            if day.lessons.count == 0{
                let entity = NSEntityDescription.entity(forEntityName: "Lesson", in: managedObjectContext)
                print("no lessons for day "+String(day.number))
                for i in 1...8{
                    let l = Lesson(entity: entity!, insertInto: managedObjectContext)
                    l.hour = i
                    l.info = ""
                    l.klasse = ""
                    l.room = ""
                    l.subject = ""
                    l.teacher = ""
                    
                    day.lessons.insert(l)
                }
            }
        }
        
        delegate.saveContext()

    }
    
    func getLessonForIndexPath(_ indexPath: IndexPath)->Lesson?{
        if let day = dayForNumber((indexPath as NSIndexPath).section), let lesson = lessonForHour((indexPath as NSIndexPath).row, forDay: day){
            return lesson
        }
        
        return nil
    }
    
    
    
    func dayForNumber(_ n: Int) -> Day?{
        var day: Day?
        for d in days{
            if d.number == n{
                day = d
            }
        }
        return day
    }
    
    func lessonForHour(_ n: Int, forDay day: Day) -> Lesson?{
        var lesson: Lesson?
        for l in day.lessons{
            if l.hour == n{
                lesson = l
            }
        }
        return lesson
    }
}
