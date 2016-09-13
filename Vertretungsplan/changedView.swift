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
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetFillColorWithColor(context, UIColor.colorFromHex("DC3023")!.CGColor)
        
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, rect.width, rect.height/2)
        CGContextAddLineToPoint(context, 0, rect.height)
        CGContextAddLineToPoint(context, 0, 0)
        
        CGContextFillPath(context);
    }

}
