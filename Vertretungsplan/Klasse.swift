//
//  Klasse.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 11.06.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation

class Klasse{
    var identifier = ""
    var raw = ""
    
    var klassen: [KlasseDescription] = []
    var kurs: String?
    var fach: String?
    
    init(descKl s: String, descLe l: String?){
        
        raw = s
        fach = l?.lowercaseString
        
        if (s.rangeOfString("/") == nil){
            identifier = s
            let class_ = s
            if class_.componentsSeparatedByString(".").count >= 2{
                let k = KlasseDescription(stufe: class_.componentsSeparatedByString(".")[0], kurs: class_.componentsSeparatedByString(".")[1])
                if !klassen.contains(k) {
                    klassen.append(k)
                }
            }
        }else{
            let p = s.componentsSeparatedByString("/")
            if (p.count == 2){
                let classes = p[0].componentsSeparatedByString(",")
                
                for class_ in classes{
                    
                    if class_.componentsSeparatedByString(".").count >= 2{
                        let k = KlasseDescription(stufe: class_.componentsSeparatedByString(".")[0], kurs: class_.componentsSeparatedByString(".")[1])
                        if !klassen.contains(k) {
                            klassen.append(k)
                        }
                    }
                }
                
                
                kurs = p[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
            }
        }
    }
    
    func applies(desc: KlasseDescription, subj: String) -> Bool{
        
        if(klassen.contains(desc)){
            let lowSubj = subj.lowercaseString
            if (lowSubj == kurs || lowSubj == fach){
                return true
            }
        }
        
        return false
    }
}

struct KlasseDescription: Equatable{
    var stufe: String
    var kurs: String
    
}


func ==(lhs: KlasseDescription, rhs: KlasseDescription) -> Bool{
    return lhs.stufe == rhs.stufe && lhs.kurs == rhs.kurs
}
