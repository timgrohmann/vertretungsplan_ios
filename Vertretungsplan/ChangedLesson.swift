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
    var rawKlasse: String = ""
    var klasse: Klasse?
    var info: String = ""
    
    var day: Int?
    var hour: Int?
    
    var identifier: String{
        return subject+teacher+room+rawKlasse+info+String(describing: day)+String(describing: hour)
    }
    
    init(subject: String, teacher: String, room: String, klasse: String, info: String, day: Int, hour: Int) {
        self.subject = subject
        self.teacher = teacher
        self.room = room
        self.rawKlasse = klasse
        self.info = info
        self.day = day
        self.hour = hour
    }
    
    init(){}
    
    func parsed(){
        self.klasse = Klasse(descKl: rawKlasse, descLe: subject)
        self.subject = klasse?.kurs ?? self.subject
    }
    
    func applies(_ lesson: Lesson, user: User)->Bool{
        
        let myKlasse = KlasseDescription(stufe: user.klassenstufe, kurs: user.klasse)
        
        if klasse?.applies(myKlasse, subj: lesson.subject) ?? false{
            return true
        }
        
        if klasse?.klassen.count == 1 && klasse?.klassen[0] == myKlasse{
            return true
        }
        
        
        
        
        return false
    }
}

func ==(lhs: ChangedLesson, rhs: ChangedLesson) -> Bool{
    return lhs.identifier == rhs.identifier
}
