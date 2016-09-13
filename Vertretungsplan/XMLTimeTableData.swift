//
//  XMLTimeTableData.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 04.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation


struct XMLTimeTableData{
    let changedLessons: [ChangedLesson]
    let schoolName: String
    let lastRefreshed: String
}