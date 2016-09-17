//
//  UIView.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 17.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit

/**
 The _Fadable_ protocol is used to fade views in/out from/to a specified area.
 - fadingView: Used to store location of start/end point. Initialize to UIView()
 */
protocol Fadable {
    var fadingView: UIView {get set}
}
extension Fadable where Self: UIView{
    
    func fadeIn(from start: UIView, size: CGSize){
        
        self.center = start.center
        self.center.x -= ((start.superview as? UIScrollView)?.contentOffset.x ?? 0)
        self.center.y += start.superview!.frame.origin.y
        
        self.bounds = start.bounds
        fadingView.frame = self.frame
        
        self.clipsToBounds = true
        self.layoutIfNeeded()
        self.alpha = 0
        self.layer.cornerRadius = 10
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
            self.center = CGPoint(x: size.width*0.5, y: size.height*0.5)
            self.bounds = CGRect(x: 0,y: 0, width: size.width - 40, height: size.height*0.4)
            self.layoutIfNeeded()
        })
        
        

    }
    
    func fadeOut(_ completion: @escaping ()->()){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.center = self.fadingView.center
            self.bounds = self.fadingView.bounds
            self.alpha = 0.0
            self.layoutIfNeeded()
            }, completion: {
                finished in
                completion()
        })
    }
}
