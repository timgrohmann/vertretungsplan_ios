//
//  JSONLoader.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 24.04.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation

class JSONLoader{
    var url: String
    
    
    init(url: String) {
        self.url = url
    }
    
    func getChanges(callback: @escaping (ChangedTimeTableData?, JSONLoadError?) -> ()) {
        if let nsurl = URL(string: self.url){
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: nsurl, completionHandler: {
                data, response, error in
                if error != nil{
                    callback(nil, JSONLoadError.couldNotLoad)
                }
                
                if let r = response as? HTTPURLResponse{
                    switch r.statusCode{
                    case 200:
                        break
                    default:
                        callback(nil, JSONLoadError.couldNotLoad)
                        break
                    }
                }
                
                if let data = data{
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]{
                        do{
                            var lessons: [ChangedLesson] = [ChangedLesson]()
                            guard let plan = json["plan"] as? [String: Any] else {throw JSONLoadError.invalidJSON}
                            guard let lRaw = plan["lessons"] as? [[String: Any]] else {throw JSONLoadError.invalidJSON}
                            
                            guard let dayFor = plan["forDay"] as? String else {throw JSONLoadError.invalidJSON}
                            let weekday = dayFor.components(separatedBy: ",")[0]
                            let days = ["Mo":0,"Di":1,"Mi":2,"Do":3,"Fr":4, "Sa": -1, "So": -1]
                            guard let day = days[weekday] else {throw JSONLoadError.dayNotFormatted}
                            
                            if day == -1 {
                                throw JSONLoadError.weekend
                            }
                            //let day = 3
                            
                            for l: [String: Any] in lRaw{
                                if let subject = l["subject"] as? String, let klasse = l["rawCourse"] as? String, let info = l["info"] as? String, let hour = l["lesson"] as? Int{
                                    
                                    let teacher = l["rawTeacher"] as? String ?? ""
                                    let room = l["room"] as? String ?? ""
                                    let newLesson = ChangedLesson(subject: subject, teacher: teacher, room: room, course: klasse, info: info, day: day, hour: hour)
                                    lessons.append(newLesson)
                                    
                                    if let rSubject = l["rSubject"] as? String {
                                        newLesson.subject = rSubject
                                    }
                                    
                                    newLesson.origTeacher = l["oTeacher"] as? String
                                    newLesson.origSubject = l["oSubject"] as? String
                                }
                            }
                            
                            guard let lastUpdated = plan["lastUpdated"] as? String else {throw JSONLoadError.invalidJSON}
                            guard let schoolName = plan["school_name"] as? String else {throw JSONLoadError.invalidJSON}
                            callback(ChangedTimeTableData(changedLessons: lessons, schoolName: schoolName, lastRefreshed: lastUpdated), nil)
                        }catch let e as JSONLoadError{
                            callback(nil, e)
                        }catch{
                            callback(nil, .unknown)
                        }
                    }
                }
                
            })
            task.resume()
        }else{
            callback(nil, JSONLoadError.invalidURL)
        }
    }
}

enum JSONLoadError: Error {
    case dayNotFormatted
    case invalidJSON
    case JSONNotParsable
    case invalidURL
    case outOfStock
    case couldNotLoad
    case unknown
    case weekend
}
