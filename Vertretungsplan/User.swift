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
    
    func loadSchoolProperties(_ completion: @escaping (_ notification: String?)->()){
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: URL(string: schoollink)!, completionHandler: {
            dataOpt, response, error in
            
            DispatchQueue.main.async{
                if let data = dataOpt{
                    if let school = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]{
                        if let name = school["name"] as? String, let link = school["link"] as? String, let primary = school["primaryColor"] as? String, let secondary = school["secondaryColor"] as? String, let textColor = school["textColor"] as? String, let secText = school["textOnSec"] as? String{
                            
                            self.schoolname = name
                            self.timetablelink = link
                            self.primaryColor = primary
                            self.secondaryColor = secondary
                            self.textColor = textColor
                            self.textOnSecondaryColor = secText
                            delegate.saveContext()
                            completion(nil)
                        }
                    }else{
                        if (response as? HTTPURLResponse)?.statusCode == 404{
                            completion("Die Schuleigenschaften konnten nicht von '"+self.schoollink+"' abgerufen werden, öffne die Einstellungen um deine Schule erneut einzurichten.")
                        }else{
                            completion("\""+self.schoollink + "\" ist keine gültige JSON-Datei.")
                        }
                        
                    }
                }else{
                    completion("Serververbindung fehlgeschlagen")
                }
            }
            
        })
        
        task.resume()
        
    }
}
