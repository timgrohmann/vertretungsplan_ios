//
//  School.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 16.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class School: NSManagedObject{
    @NSManaged var name: String
    
    @NSManaged var timetablelink: String
    @NSManaged var primaryColor: String
    @NSManaged var secondaryColor: String
    @NSManaged var textColor: String
    @NSManaged var textOnSecondaryColor: String
    
    @NSManaged var timeschemes: Set<TimeSchemeLesson>
    
    var colorPrimary: UIColor?{
        return UIColor.colorFromHex(primaryColor)
    }
    var colorSecondary: UIColor?{
        return UIColor.colorFromHex(secondaryColor)
    }
    var colorText: UIColor?{
        return UIColor.colorFromHex(textColor)
    }
    var colorTextSecondary: UIColor?{
        return UIColor.colorFromHex(textOnSecondaryColor)
    }
    
    func use(fetchResult: SchoolFetchResult){
        timeschemes.removeAll()
        
        self.timetablelink = fetchResult.link
        self.name = fetchResult.name
        self.primaryColor = fetchResult.primaryColor
        self.secondaryColor = fetchResult.secondaryColor
        self.textColor = fetchResult.textColor
        self.textOnSecondaryColor = fetchResult.textOnSec
        
        for ts in fetchResult.timescheme{
            let a = TimeSchemeLesson(entity: NSEntityDescription.entity(forEntityName: "TimeSchemeLesson", in: delegate.managedObjectContext)!, insertInto: delegate.managedObjectContext)
            a.start = ts.start
            a.connectedToNext = ts.connectedToNext
            a.connectedToPrevious = ts.connectedToPrevious
            a.duration = ts.duration
            a.lessonNumber = ts.lessonNumber
            
            timeschemes.insert(a)
        }
        
        //print(fetchResult)
    }
    
    func compute(lessons: [[String:Any]]) throws{
        timeschemes.removeAll()

        for (index, l) in lessons.enumerated(){
            if let startTime = l["startTime"] as? String, let next = l["n"] as? Bool, let prev = l["p"] as? Bool, let dur = l["d"] as? Int{
                let a = TimeSchemeLesson(entity: NSEntityDescription.entity(forEntityName: "TimeSchemeLesson", in: delegate.managedObjectContext)!, insertInto: delegate.managedObjectContext)
                a.start = startTime
                a.connectedToNext = next
                a.connectedToPrevious = prev
                a.duration = dur
                a.lessonNumber = index
                
                timeschemes.insert(a)
            }else{
                throw NSError(domain: "Vertretungsplan", code: 100, userInfo: [:])
            }
        }
    }
    
    func getTimeScheme(for lessonNumber: Int) -> TimeSchemeLesson?{
        for l in timeschemes{
            if l.lessonNumber == lessonNumber{
                return l
            }
        }
        return nil
    }
}







