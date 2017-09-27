//
//  User.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 04.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit
import CoreData

class User: NSManagedObject{
    @NSManaged var klassenstufe: String
    @NSManaged var klasse: String
    @NSManaged var username: String
    @NSManaged var password: String
    
    @NSManaged var school: School?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
        if school == nil{
            school = School(entity: NSEntityDescription.entity(forEntityName: "School", in: delegate.managedObjectContext)!, insertInto: delegate.managedObjectContext)
        }
    }
}
