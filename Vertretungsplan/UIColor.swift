//
//  UIColor.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 16.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    class func colorFromHex(hex: String) -> UIColor?{
        if hex.characters.count != 6 {return nil} //Not formatted correctly
        
        guard let rgb = Int(hex, radix: 16) else {return nil}
        
        let r = CGFloat((rgb & 0xFF0000) >> 16)/255
        let g = CGFloat((rgb & 0xFF00) >> 8)/255
        let b = CGFloat(rgb & 0xFF)/255
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    class func colorFromHex(hex: String, alpha: Float) -> UIColor?{
        if hex.characters.count != 6 {return nil} //Not formatted correctly
        
        guard let rgb = Int(hex, radix: 16) else {return nil}
        
        let r = CGFloat((rgb & 0xFF0000) >> 16)/255
        let g = CGFloat((rgb & 0xFF00) >> 8)/255
        let b = CGFloat(rgb & 0xFF)/255
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
}