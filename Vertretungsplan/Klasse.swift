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
        fach = l?.lowercased()
        
        if (s.range(of: "/") == nil){
            identifier = s
            let class_ = s
            if class_.components(separatedBy: ".").count >= 2{
                let k = KlasseDescription(stufe: class_.components(separatedBy: ".")[0], kurs: class_.components(separatedBy: ".")[1])
                if !klassen.contains(k) {
                    klassen.append(k)
                }
            }
        }else{
            let p = s.components(separatedBy: "/")
            if (p.count == 2){
                let classes = p[0].components(separatedBy: ",")
                
                for class_ in classes{
                    
                    if class_.components(separatedBy: ".").count >= 2{
                        let k = KlasseDescription(stufe: class_.components(separatedBy: ".")[0], kurs: class_.components(separatedBy: ".")[1])
                        if !klassen.contains(k) {
                            klassen.append(k)
                        }
                    }
                }
                
                
                kurs = p[1].trimmingCharacters(in: .whitespaces).lowercased()
            }
        }
    }
    
    func applies(_ desc: KlasseDescription, subj: String) -> Bool{
        
        if(klassen.contains(desc)){
            let lowSubj = subj.lowercased()
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
