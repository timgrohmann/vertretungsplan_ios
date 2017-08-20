//
//  WatchDay.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 19.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import Foundation

struct WatchDay{
    var dayNumber: Int
    var lessons: [WatchLesson] = []
    
    init(number: Int, rawData: [String:Any]){
        dayNumber = number
        for i in 1...10 {
            if let lessonRaw = rawData[String(i)] as? [String:Any] {
                let lesson = WatchLesson(number: i, rawData: lessonRaw)
                lessons.append(lesson)
            }
        }
    }
}
