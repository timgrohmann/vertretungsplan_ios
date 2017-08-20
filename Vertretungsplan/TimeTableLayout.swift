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
    
    override func prepare() {
        
        cellWidth = self.collectionView!.frame.size.width
        cellHeight = self.collectionView!.frame.size.height / 8
    }

    
    override var collectionViewContentSize : CGSize {
        let coloumns = self.collectionView!.numberOfSections
        var rows = 0
        for c in 0..<coloumns{
            if (self.collectionView!.numberOfItems(inSection: c)>rows){
                rows = self.collectionView!.numberOfItems(inSection: 0)
            }
        }
        return CGSize(width: cellWidth*CGFloat(coloumns),height: cellHeight*CGFloat(rows))
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        
        for i in 0..<self.collectionView!.numberOfSections{
            for j in 0..<self.collectionView!.numberOfItems(inSection: i){
                //i: coloumn
                //j: row
                var cellFrame: CGRect
                cellFrame = frameForItemAt(indexPath: IndexPath(row: j, section: i))
                
                if(cellFrame.intersects(rect)){
                    let indexPath = IndexPath(row: j, section: i)
                    var attr: UICollectionViewLayoutAttributes
                    
                    attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attr.frame = cellFrame
                    
                    layoutAttributes.append(attr)
                }
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attr.frame = frameForItemAt(indexPath: indexPath)
        return attr
    }
    
    func frameForItemAt(indexPath: IndexPath) -> CGRect{
        return CGRect(x: CGFloat((indexPath as NSIndexPath).section)*cellWidth, y: CGFloat((indexPath as NSIndexPath).row)*cellHeight, width: cellWidth, height: ceil(cellHeight))
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
