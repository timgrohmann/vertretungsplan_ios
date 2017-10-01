//
//  SchoolFetcher.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 04.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class SchoolFetcher{
    var schools: [SchoolFetchResult] = []
    var url = "https://vpman.146programming.de/schools-ext"
    
    func fetch(_ completion:@escaping (_ successful: [SchoolFetchResult], _ notification: String?)->()){
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var ret: [SchoolFetchResult] = []
        let task = session.dataTask(with: URL(string: url)!, completionHandler: {
            dataOpt, response, error in
            
            
            
            if let data = dataOpt{
                if let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any]{
                    guard let status = json["status"] as? Int, status == 200 else {
                        DispatchQueue.main.async{
                            completion([], "Fehler beim Abrufen der Schulen (c01)")
                        }
                        return
                    }
                    guard let rawSchools = json["schools"] as? [[String:Any]] else {
                        DispatchQueue.main.async{
                            completion([], "Fehler beim Abrufen der Schulen (f01)")
                        }
                        return
                    }
                    for school in rawSchools{
                        if let name = school["name"] as? String, let link = school["link"] as? String,  let primaryColor = school["primaryColor"] as? String,  let secondaryColor = school["secondaryColor"] as? String,  let textColor = school["textColor"] as? String,  let textOnSec = school["textOnSec"] as? String, let rawTs = school["lessons"] as? [[String:Any]]{
                            
                            var timeSchemeLessonFetchResults: [TimeSchemeLessonFetchResult] = []
                            
                            for (i, l) in rawTs.enumerated(){
                                if let startTime = l["startTime"] as? String, let n = l["n"] as? Bool, let p = l["p"] as? Bool, let d = l["d"] as? Int{
                                    timeSchemeLessonFetchResults.append(TimeSchemeLessonFetchResult(lessonNumber: i, connectedToPrevious: p, connectedToNext: n, start: startTime, duration: d))
                                }
                            }
                            
                            
                            let newRes = SchoolFetchResult(link: link, name: name, primaryColor: primaryColor, secondaryColor: secondaryColor, textColor: textColor, textOnSec: textOnSec, timescheme: timeSchemeLessonFetchResults)
                            
                            
                            
                            ret.append(newRes)
                                                        
                        }else{
                            DispatchQueue.main.async{
                                completion([], "Fehler beim Abrufen der Schulen (f02)")
                            }
                            return
                        }
                    }
                    DispatchQueue.main.async{
                        completion(ret, nil)
                        return
                    }
                }
            }else{
                DispatchQueue.main.async{
                    completion([], "Fehler beim Abrufen der Schulen (c00)")
                }
            }
            
        })
        
        task.resume()
    }
}

struct SchoolFetchResult {
    var link: String
    var name: String
    var primaryColor: String
    var secondaryColor: String
    var textColor: String
    var textOnSec: String
    
    var timescheme: [TimeSchemeLessonFetchResult]
}

struct TimeSchemeLessonFetchResult {
    var lessonNumber: Int
    
    var connectedToPrevious: Bool
    var connectedToNext: Bool
    
    var start: String
    
    var duration: Int
}
