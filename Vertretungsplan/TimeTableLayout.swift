//
//  TimeTableLayout.swift
//  Vertretungsplan
//
//  Created by Tim Grohmann on 14.08.16.
//  Copyright © 2016 Tim Grohmann. All rights reserved.
//

import Foundation
import UIKit

class TimeTableLayout: UICollectionViewLayout{
    
    
    var cellWidth: CGFloat = 0.0
    var cellHeight: CGFloat = 0.0
    
    override func prepareLayout() {
        
        cellWidth = self.collectionView!.frame.size.width
        cellHeight = self.collectionView!.frame.size.height / 8
    }

    
    override func collectionViewContentSize() -> CGSize {
        let coloumns = self.collectionView!.numberOfSections()
        var rows = 0
        for c in 0..<coloumns{
            if (self.collectionView!.numberOfItemsInSection(c)>rows){
                rows = self.collectionView!.numberOfItemsInSection(0)
            }
        }
        return CGSizeMake(cellWidth*CGFloat(coloumns),cellHeight*CGFloat(rows))
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        
        for i in 0..<self.collectionView!.numberOfSections(){
            for j in 0..<self.collectionView!.numberOfItemsInSection(i){
                //i: coloumn
                //j: row
                var cellFrame: CGRect
                cellFrame = frameForItemAt(indexPath: NSIndexPath(forRow: j, inSection: i))
                
                if(CGRectIntersectsRect(cellFrame, rect)){
                    let indexPath = NSIndexPath(forRow: j, inSection: i)
                    var attr: UICollectionViewLayoutAttributes
                    
                    attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    attr.frame = cellFrame
                    
                    layoutAttributes.append(attr)
                }
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attr.frame = frameForItemAt(indexPath: indexPath)
        return attr
    }
    
    func frameForItemAt(indexPath indexPath: NSIndexPath) -> CGRect{
        return CGRectMake(CGFloat(indexPath.section)*cellWidth, CGFloat(indexPath.row)*cellHeight, cellWidth, ceil(cellHeight))
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}

















