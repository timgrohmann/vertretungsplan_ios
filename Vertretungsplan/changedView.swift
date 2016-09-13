//
//  changedView.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 07.09.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import UIKit

class ChangedView: UIView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.colorFromHex("DC3023")!.cgColor)
        
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height/2))
        context.addLine(to: CGPoint(x: 0, y: rect.height))
        context.addLine(to: CGPoint(x: 0, y: 0))
        
        context.fillPath();
    }

}
