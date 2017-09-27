//
//  XMLParser.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 11.06.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit

class XMLParser: NSObject, XMLParserDelegate{
    var parser: Foundation.XMLParser?
    var url: String
    var parsed: NSDictionary = NSDictionary()
    var callback: (ChangedTimeTableData)->()
    
    var lessons: [ChangedLesson] = []
    
    var inLesson = false
    var currentLesson: ChangedLesson = ChangedLesson()
    
    var inHour = false
    var inSubject = false
    var inTeacher = false
    var inRoom = false
    var inKlasse = false
    var inInfo = false
    
    var inLastRefreshed = false
    var inSchoolName = false
    var lastRefreshed = ""
    var schoolName = ""
    
    
    var inTitle = false
    var title = ""
    var day: Int?
    
    
    func parser(_ parser: Foundation.XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]){
    
        switch elementName{
        case "aktion":
            inLesson = true
            lessons.append(ChangedLesson())
            break
        case "klasse":
            inKlasse = true
            break
        case "stunde":
            inHour = true
            break
        case "fach":
            inSubject = true
            break
        case "lehrer":
            inTeacher = true
            break
        case "raum":
            inRoom = true
            break
        case "info":
            inInfo = true
            break
        case "titel":
            inTitle = true
            break
        case "datum":
            inLastRefreshed = true
            break
        case "schulname":
            inSchoolName = true
            break
        default:
            break
        }
        
        
    }
    
    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
       
        
        if inHour{
            lessons.last?.hour = Int(string) ?? 0
        }
        if inSubject{
            lessons.last?.subject += string
        }
        if inTeacher{
            lessons.last?.teacher += string
        }
        if inRoom{
            lessons.last?.room += string
        }
        if inKlasse{
            //lessons.last?.rawKlasse += string
        }
        if inInfo{
            lessons.last?.info += string
        }
        if inTitle{
            title += string
        }
        if inLastRefreshed{
            lastRefreshed += string
        }
        if inSchoolName{
            schoolName += string
        }
        
    }
    
    func parser(_ parser: Foundation.XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName{
        case "aktion":
            lessons.last?.day = day
            //lessons.last?.parsed()
            inLesson = false
            break
        case "klasse":
            inKlasse = false
            break
        case "stunde":
            inHour = false
            break
        case "fach":
            inSubject = false
            break
        case "lehrer":
            inTeacher = false
            break
        case "raum":
            inRoom = false
            break
        case "info":
            inInfo = false
            break
        case "titel":
            inTitle = false
                        
            let dayName = title.components(separatedBy: ",")[0]
            let days = ["Montag":0,"Dienstag":1,"Mittwoch":2,"Donnerstag":3,"Freitag":4]
            
            day = days[dayName]
            
            
            
            break
        case "datum":
            inLastRefreshed = false
            break
        case "schulname":
            inSchoolName = false
            break
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: Foundation.XMLParser) {
        let data = ChangedTimeTableData(changedLessons: lessons, schoolName: schoolName, lastRefreshed: lastRefreshed)
        self.callback(data)
        
    }
    
    func parser(_ parser: Foundation.XMLParser, parseErrorOccurred parseError: Error) {
        callback(ChangedTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan hat falsches Dateiformat. Bitte melde dich bei deiner Schule."))
        //reset callback to stop recalling it with parserDidEndDocument:
        self.callback = {_ in}
    }
    
    init(url: String, callback: @escaping (ChangedTimeTableData)->()) {
        
        self.url = url
        self.callback = callback
        super.init()
        
        if let nsurl = URL(string: url){
            
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: nsurl, completionHandler: {
                data, response, error in
                if let error = error{
                    callback(ChangedTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan konnte nicht geladen werden. "+error.localizedDescription))
                }
                
                if let r = response as? HTTPURLResponse{
                    
                    switch r.statusCode{
                    case 200:
                        break
                    case 404:
                        callback(ChangedTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan konnte nicht geladen werden. Der Vertretungsplan konnte nicht auf dem Server deiner Schule gefunden werden."))
                        break
                    default:
                        callback(ChangedTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "Vertretungsplan konnte nicht geladen werden. Unbekannter Fehler"))
                        break
                    }
                }
                
                if let data = data{
                    self.parser = Foundation.XMLParser(data: data)
                    self.parser?.delegate = self
                    self.parser?.parse()
                }
                
            })
            task.resume()
        }else{
            callback(ChangedTimeTableData(changedLessons: [], schoolName: "", lastRefreshed: "'"+url+"' ist kein gültiger Link"))
        }
    }
}
