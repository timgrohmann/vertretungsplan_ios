//
//  Day.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 14.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import CoreData


class Day: NSManagedObject {

    @NSManaged var number: Int
    @NSManaged var lessons: Set<Lesson>
    
    let names = ["Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"]

}
