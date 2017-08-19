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
    var callback: (XMLTimeTableData)->()
    
    
    init(url: String, callback: @escaping (XMLTimeTableData)->()) {
        self.url = url
        self.callback = callback
        
        if let nsurl = URL(string: url){
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: nsurl, completionHandler: {
                data, response, error in
                if let error = error{
                    callback(XMLTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan konnte nicht geladen werden. "+error.localizedDescription))
                }
                
                if let r = response as? HTTPURLResponse{
                    switch r.statusCode{
                    case 200:
                        break
                    case 404:
                        callback(XMLTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan konnte nicht geladen werden. Der Vertretungsplan konnte nicht auf dem Server deiner Schule gefunden werden."))
                        break
                    default:
                        callback(XMLTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan konnte nicht geladen werden. Unbekannter Fehler"))
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
                            let days = ["Montag":0,"Dienstag":1,"Mittwoch":2,"Donnerstag":3,"Freitag":4]
                            guard let day = days[weekday] else {throw JSONLoadError.dayNotFormatted}
                            
                            for l: [String: Any] in lRaw{
                                if let subject = l["subject"] as? String, let klasse = l["rawCourse"] as? String, let info = l["info"] as? String, let hour = l["lesson"] as? Int{
                                    
                                    let teacher = l["rawTeacher"] as? String ?? ""
                                    let room = l["room"] as? String ?? ""
                                    lessons.append(ChangedLesson(subject: subject, teacher: teacher, room: room, course: klasse, info: info, day: day, hour: hour))
                                }
                            }
                            
                            guard let lastUpdated = plan["lastUpdated"] as? String else {throw JSONLoadError.invalidJSON}
                            guard let schoolName = plan["school_name"] as? String else {throw JSONLoadError.invalidJSON}
                            callback(XMLTimeTableData(changedLessons: lessons, schoolName: schoolName, lastRefreshed: lastUpdated))
                        }catch{
                            print("Error")
                        }
                    }
                }
                
            })
            task.resume()
        }else{
            callback(XMLTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "'"+url+"' ist kein gültiger Link"))
        }

    }
}

enum JSONLoadError: Error {
    case dayNotFormatted
    case invalidJSON
    case outOfStock
}
