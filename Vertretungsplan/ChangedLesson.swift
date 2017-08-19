//
//  ChangedLesson.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 15.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ChangedLesson: Equatable{
    
    var subject: String = ""
    var teacher: String = ""
    var room: String = ""
    var course: String = ""
    var info: String = ""
    
    var day: Int?
    var hour: Int?
    
    var identifier: String{
        return subject+teacher+room+course+info+String(describing: day)+String(describing: hour)
    }
    
    init(subject: String, teacher: String, room: String, course: String, info: String, day: Int, hour: Int) {
        self.subject = subject
        self.teacher = teacher
        self.room = room
        self.course = course
        self.info = info
        self.day = day
        self.hour = hour
    }
    
    init(){}
    
    func applies(_ lesson: Lesson, user: User)->Bool{
        
        if (course.lowercased() ==  lesson.course.lowercased()){
            return true
        }
        
        /*if klasse?.klassen.count == 1 && klasse?.klassen[0] == myKlasse{
            return true
        }*/
        
        return false
    }
}

func ==(lhs: ChangedLesson, rhs: ChangedLesson) -> Bool{
    return lhs.identifier == rhs.identifier
}
