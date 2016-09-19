//
//  TimeScheme.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 19.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import CoreData

class TimeSchemeLesson: NSManagedObject{
    @NSManaged var lessonNumber: Int
    
    @NSManaged var connectedToPrevious: Bool
    @NSManaged var connectedToNext: Bool
    
    @NSManaged var start: String
    
    @NSManaged var duration: Int
    
    var startTime: Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: start)
    }
    
    var endTime: Date?{
        return startTime?.addingTimeInterval(60.0 * Double(duration))
    }
}
