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
    var schools: [School] = []
    var url = "https://146programming.de/vp/schools.json"
    
    func fetch(completion:(successful: [School], notification: String?)->()){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var ret: [School] = []
        let task = session.dataTaskWithURL(NSURL(string: url)!){
            dataOpt, response, error in
            
            
            
            if let data = dataOpt{
                if let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? [AnyObject]{
                    for school in json{
                        if let name = school["name"] as? String, link = school["link"] as? String, id = school["id"] as? Int{
                            
                            ret.append(School(link: link, name: name, id: id))
                                                        
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        completion(successful: ret, notification: nil)
                        return
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()){
                    completion(successful: ret, notification: "Verbindung zum Hauptserver konnte nicht aufgebaut werden.")
                }
            }
            
        }
        
        task.resume()
    }
}