//
//  WatchDataExtension.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 17.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class WatchDataExtension: NSObject, WCSessionDelegate{
    
    let session = WCSession.default
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }else{
            print("WCSession not supported!")
        }
    }
    
    func sendWatchData(){
        if let rawData: [String:Any] = getEncodedData() {
            if session.activationState == .activated{
                session.transferCurrentComplicationUserInfo(rawData)
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
        if let error = error {print(error)}
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["intent"] as? String == "reload" {
            print("watch wants new data")
            DispatchQueue.main.async {
                if let rawData = self.getEncodedData(){
                    print("Data message sent")
                    replyHandler(["data":rawData])
                }else{
                    replyHandler(["error":"Data object construction failed"])
                    print("Data object construction failed")
                }
            }
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {print("_:didFinish",error)}
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print(":sessionDidDeactivate")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print(":sessionDidBecomeInactive")
    }
    
    func getEncodedData() -> [String:Any]? {
        if let vc = (delegate.window?.rootViewController as? UINavigationController)?.viewControllers.first as? ViewController {
            let timetable = vc.timetable
            let changedTimeTable = vc.changedTimetable
            changedTimeTable.refreshChanged()

            let timescheme = Array(vc.user?.school?.timeschemes ?? [])
            var rawData: [String:Any] = [:]
            
            let days = timetable.days
            
            
            for day in days {
                var dayLessons: [String:Any] = [:]
                
                for lesson in day.lessons{
                    var lessonRawified: [String:Any] = [:]
                    
                    
                    
                    lessonRawified["subj"] = lesson.subject.capitalized
                    lessonRawified["room"] = lesson.room.capitalized
                    
                    if let change = changedTimeTable.getChange(lesson){
                        lessonRawified["subj"] = change.subject.capitalized
                        lessonRawified["room"] = change.room.capitalized
                        lessonRawified["change"] = true
                    }
                    
                    if lesson.subject != "" {
                        dayLessons[String(lesson.hour)] = lessonRawified
                    }
                }
                
                rawData[String(day.number)] = dayLessons
            }
            
            
            var timeRaw: [String:Any] = [:]
            for time in timescheme {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                if let from = time.startTime, let to = time.endTime{
                    timeRaw[String(time.lessonNumber)] = ["from": formatter.string(from: from), "to": formatter.string(from: to)]
                }
            }
            
            rawData["timescheme"] = timeRaw
            
            return rawData
        }
        
        return nil
    }
}
