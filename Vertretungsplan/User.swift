//
//  User.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 04.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit
import CoreData

class User: NSManagedObject{
    @NSManaged var klassenstufe: String
    @NSManaged var klasse: String
    
    
    @NSManaged var schoollink: String
    @NSManaged var timetablelink: String
    @NSManaged var schoolname: String
    @NSManaged var schoolid: Int
    @NSManaged var primaryColor: String
    @NSManaged var secondaryColor: String
    @NSManaged var textColor: String
    @NSManaged var textOnSecondaryColor: String
    
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
    
    func loadSchoolProperties(completion: (notification: String?)->()){
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(NSURL(string: schoollink)!){
            dataOpt, response, error in
            
            dispatch_async(dispatch_get_main_queue()){
                if let data = dataOpt{
                    if let school = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)){
                        if let name = school["name"] as? String, link = school["link"] as? String, primary = school["primaryColor"] as? String, secondary = school["secondaryColor"] as? String, textColor = school["textColor"] as? String, secText = school["textOnSec"] as? String{
                            
                            self.schoolname = name
                            self.timetablelink = link
                            self.primaryColor = primary
                            self.secondaryColor = secondary
                            self.textColor = textColor
                            self.textOnSecondaryColor = secText
                            delegate.saveContext()
                            completion(notification: nil)
                        }
                    }else{
                        if (response as? NSHTTPURLResponse)?.statusCode == 404{
                            completion(notification: "Die Schuleigenschaften konnten nicht von '"+self.schoollink+"' abgerufen werden, öffne die Einstellungen um deine Schule erneut einzurichten.")
                        }else{
                            completion(notification: "\""+self.schoollink + "\" ist keine gültige JSON-Datei.")
                        }
                        
                    }
                }else{
                    completion(notification: "Serververbindung fehlgeschlagen")
                }
            }
            
        }
        
        task.resume()
        
    }
}