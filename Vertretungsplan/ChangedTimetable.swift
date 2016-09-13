//
//  ChangedTimetable.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 15.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ChangedTimetable{
    var parser: XMLParser?
    //var changedLessons: [ChangedLesson] = []
    var applyingLessons: [ChangedLesson] = []
    var data: XMLTimeTableData?
    var loaded = false
    var user: User?{
        do{
            let us = try managedObjectContext.executeFetchRequest(NSFetchRequest(entityName: "User")) as! [User]
            return us[0]
        }catch{
            print(error)
        }
        return nil
    }
    
    func load(completion: ()->()){
        
        guard let user = user else{
            return
        }
        
        parser = XMLParser(url: user.timetablelink){
            data in
            self.data = data
            self.loaded = true
            
            dispatch_async(dispatch_get_main_queue()){
                self.refreshChanged()
                completion()
            }
        }
    }
    
    func refreshChanged(){
        let timetable = Timetable()
        applyingLessons = []
        var allLessons: [Lesson] = []
        for day in timetable.days{
            allLessons.appendContentsOf(day.lessons)
        }
        
        if let d = data, u = user{
            for changedLesson in d.changedLessons{
                for lesson in allLessons{
                    if changedLesson.applies(lesson,user: u) {
                        if !applyingLessons.contains(changedLesson){
                            applyingLessons.append(changedLesson)
                        }
                    }
                }
            }
        }
        
        print("Number of changes that apply:  "+String(applyingLessons.count))
    }
    
    func getChange(lesson: Lesson) -> ChangedLesson?{
        for changedLesson in applyingLessons{
            if(changedLesson.day == lesson.day.number && changedLesson.hour == lesson.hour){
                return changedLesson
            }
        }
        return nil
    }
}