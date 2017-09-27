//
//  LoaderWrapper.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 27.09.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation

class LoaderWrapper{
    var url: String
    var username: String?
    var password: String?
    
    var loaders: [JSONLoader] = []
    
    var failed = 0
    
    var dataElements: [ChangedTimeTableData] = []
    
    var completionHandler: (ChangedTimeTableData) -> () = {_ in }
    
    init(url: String, username: String?, password: String?) {
        self.url = url + "?"
        self.username = username
        self.password = password
        
        if let u = username, u != "" {
            self.url += "acun=" + u + "&"
        }
        if let p = password, p != "" {
            self.url += "acpw=" + p.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&"
        }
        
        for i in 0...4 {
            let loader = JSONLoader(url: self.url + "page=" + String(i))
            loaders.append(loader)
        }
    }
    
    func load(completion: @escaping (ChangedTimeTableData) -> ()){
        self.completionHandler = completion
        
        for loader in loaders {
            loader.getChanges() {
                data, error in
                
                if error != nil{
                    self.failed += 1
                }
                
                guard let data = data else {return}
                
                self.dataElements.append(data)
                DispatchQueue.main.async {
                    self.checkDone()
                }
            }
        }
    }
    
    func checkDone(){
        if (dataElements.count + failed == loaders.count){
            var allLessons: [ChangedLesson] = []
            for d in dataElements{
                allLessons.append(contentsOf: d.changedLessons)
            }
            completionHandler(ChangedTimeTableData(changedLessons: allLessons, schoolName: dataElements[0].schoolName, lastRefreshed: dataElements[0].lastRefreshed))
        }
    }
    
}
