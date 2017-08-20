//
//  InterfaceController.swift
//  Vertretungsplan_Watch Extension
//
//  Created by Tim Grohmann on 17.08.17.
//  Copyright © 2017 Tim Grohmann. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    var session : WCSession?
    
    @IBOutlet var timeTable: WKInterfaceTable!
    
    var currentDisplayWeekDay = 0 {
        didSet {
            let displayDate = Calendar.current.date(bySetting: .weekday, value: currentDisplayWeekDay + 2, of: Date())
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE"
            self.setTitle(weekdayFormatter.string(from: displayDate ?? Date()))
        }
    }
    
    var data: WatchVPData {
        return (WKExtension.shared().delegate as! ExtensionDelegate).currentData
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setTitle("Stundenplan")
        
        print(":awake")
        // Configure interface objects here.
        
        session = WCSession.default()
        session?.delegate = self
        session?.activate()
        
        loadTable(today: true)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(":activationDidCompleteWith",activationState)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        print(":didReceiveUserInfo")
        DispatchQueue.main.async {
            self.loadTable(today: false)
        }
        (WKExtension.shared().delegate as! ExtensionDelegate).currentData.refreshData(userInfo: userInfo)
    }
    
    func loadTable(today: Bool) {
        /*let intFormatter = DateFormatter()
        intFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let date = intFormatter.date(from: "21.08.2017 09:30")!*/
        let date = Date()
        
        if today {
            currentDisplayWeekDay = Calendar.current.component(.weekday, from: date) - 2
            if [-1,5].contains(currentDisplayWeekDay) {
                currentDisplayWeekDay = 0
            }
        }
        
        
        
        if let todaysData = data.days[currentDisplayWeekDay]?.lessons {
            self.timeTable.setNumberOfRows(todaysData.count, withRowType: "MainRowType")
            let rowCount = self.timeTable.numberOfRows
            
            // Iterate over the rows and set the label and image for each one.
            for i in 0..<rowCount {
                // Set the values for the row controller
                let row = self.timeTable.rowController(at: i) as! TimeTableRowController
                
                row.setLesson(to: todaysData[i])
            }
        }
    }
    
    @IBAction func reloadByMenu() {
        //loadTable(today: true)
        
        session?.sendMessage(["intent":"reload"], replyHandler: {
            replyData in
            if let rawReply = replyData["data"] as? [String:Any] {
                DispatchQueue.main.async {
                    (WKExtension.shared().delegate as! ExtensionDelegate).currentData.refreshData(userInfo: rawReply)
                    self.loadTable(today: true)
                }
            }
            
        }, errorHandler: nil)
        
    }
    
    @IBAction func sweptRight(_ sender: Any) {
        if currentDisplayWeekDay > 0 {
            currentDisplayWeekDay -= 1
            loadTable(today: false)
        }
    }
    
    @IBAction func sweptLeft(_ sender: Any) {
        if currentDisplayWeekDay < 4 {
            currentDisplayWeekDay += 1
            loadTable(today: false)
        }
    }
    
    
}
