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
    @NSManaged var link: String
    @NSManaged var name: String
    @NSManaged var id: Int
    
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
    
    func loadProperties(_ completion: @escaping (_ notification: String?)->()){
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        guard let url = URL(string: link) else{
            completion("Schule muss neu eingerichtet werden.")
            return
        }
        
        let task = session.dataTask(with: url, completionHandler: {
            dataOpt, response, error in
            
            DispatchQueue.main.async{
                if let data = dataOpt{
                    if let school = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]{
                        if let name = school["name"] as? String, let link = school["link"] as? String, let primary = school["primaryColor"] as? String, let secondary = school["secondaryColor"] as? String, let textColor = school["textColor"] as? String, let secText = school["textOnSec"] as? String, let lessons = school["lessons"] as? [[String:Any]]{
                            
                            self.name = name
                            self.timetablelink = link
                            self.primaryColor = primary
                            self.secondaryColor = secondary
                            self.textColor = textColor
                            self.textOnSecondaryColor = secText
                            delegate.saveContext()
                            do{
                                try self.compute(lessons: lessons)
                            }catch{
                                completion("Fehler beim parsen der Stundendaten")
                            }
                            
                            completion(nil)
                            
                            
                            
                        }
                    }else{
                        if (response as? HTTPURLResponse)?.statusCode == 404{
                            completion("Die Schuleigenschaften konnten nicht von '"+self.link+"' abgerufen werden, öffne die Einstellungen um deine Schule erneut einzurichten.")
                        }else{
                            completion("\""+self.link + "\" ist keine gültige JSON-Datei.")
                        }
                        
                    }
                }else{
                    completion("Serververbindung fehlgeschlagen")
                }
            }
            
        })
        
        task.resume()
        
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







