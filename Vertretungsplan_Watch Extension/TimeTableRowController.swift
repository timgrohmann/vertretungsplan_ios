//
//  TimeTableRowController.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 19.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import WatchKit

class TimeTableRowController: NSObject {
    @IBOutlet var hourLabel: WKInterfaceLabel!
    @IBOutlet var subjectLabel: WKInterfaceLabel!
    @IBOutlet var roomLabel: WKInterfaceLabel!
    
    func setLesson(to lesson: WatchLesson){
        hourLabel.setText(String(lesson.hour))
        subjectLabel.setText(lesson.subject_short)
        roomLabel.setText(lesson.room.uppercased())
    }
}
