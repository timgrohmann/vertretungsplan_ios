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
    var parser: LoaderWrapper?
    var applyingLessons: [ChangedLesson] = []
    var data: ChangedTimeTableData?
    
    var loaded = false
    var user: User?{
        do{
            let us = try managedObjectContext.fetch(NSFetchRequest(entityName: "User"))
            return us[0] as? User
        }catch{
            print(error)
        }
        return nil
    }
    
    func load(_ completion: @escaping ()->()){
        
        guard let user = user else{
            return
        }
        
        parser = LoaderWrapper(url: user.school!.timetablelink, username: user.username, password: user.password)
        parser?.load(){
            data, error in
            
            if error != nil{
                self.data = ChangedTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Ein Fehler ist aufgetreten!")
                DispatchQueue.main.async{
                    completion()
                }
                return
            }
            
            self.data = data
            self.loaded = true
            
            DispatchQueue.main.async{
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
            allLessons.append(contentsOf: day.lessons)
        }
        
        
        if let d = data, let u = user{
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
    
    func getChange(_ lesson: Lesson) -> ChangedLesson?{
        for changedLesson in applyingLessons{
            if(changedLesson.day == lesson.day.number && changedLesson.hour == lesson.hour){
                return changedLesson
            }
        }
        return nil
    }
}
