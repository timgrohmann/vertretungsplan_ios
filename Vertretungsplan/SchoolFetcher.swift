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
    var schools: [SchoolSummary] = []
    var url = "https://146programming.de/vp/schools.json"
    
    func fetch(_ completion:@escaping (_ successful: [SchoolSummary], _ notification: String?)->()){
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var ret: [SchoolSummary] = []
        let task = session.dataTask(with: URL(string: url)!, completionHandler: {
            dataOpt, response, error in
            
            
            
            if let data = dataOpt{
                if let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [AnyObject]{
                    for school in json{
                        if let name = school["name"] as? String, let link = school["link"] as? String, let id = school["id"] as? Int{
                            
                            ret.append(SchoolSummary(link: link, name: name, id: id))
                                                        
                        }
                    }
                    DispatchQueue.main.async{
                        completion(ret, nil)
                        return
                    }
                }
            }else{
                DispatchQueue.main.async{
                    completion(ret, "Verbindung zum Hauptserver konnte nicht aufgebaut werden.")
                }
            }
            
        })
        
        task.resume()
    }
}

struct SchoolSummary{
    var link: String
    var name: String
    var id: Int
}
