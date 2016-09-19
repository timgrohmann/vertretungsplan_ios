//
//  Lesson.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 11.06.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import CoreData

class Lesson: NSManagedObject{
        
    @NSManaged var hour: Int
    @NSManaged var subject: String
    @NSManaged var teacher: String
    @NSManaged var room: String
    @NSManaged var klasse: String
    @NSManaged var info: String
    @NSManaged var day: Day
    
    var connectedToTop: Bool = false
    var connectedBottom: Bool = false
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    func setHourString(_ s:String){
        if let i = Int(s){
            self.hour = i;
        }
    }
}
