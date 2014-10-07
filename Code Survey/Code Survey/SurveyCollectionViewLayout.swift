//
//  SurveyCollectionViewLayout.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class SurveyCollectionViewLayout: SEUICollectionViewLayout {
    
    // MARK: - Properties
    
    var checkboxSize:CGSize = CGSizeMake(10, 10) {
        didSet {
            invalidateLayout()
        }
    }
    
    var textSize:CGSize = CGSizeMake(100, 50) {
        didSet {
            invalidateLayout()
        }
    }
    
    var bigTextHeight:CGFloat = 50 {
        didSet {
            invalidateLayout()
        }
    }
    
    var itemSpacing:CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    
    var margin:CGFloat = 10 {
        didSet {
            invalidateLayout()
        }
    }
    
    var maxWidth:CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }
    
    // MARK: - Delegate wrappers
    
    private var collectionViewDelegate: UICollectionViewDelegateSurveyLayout {
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateSurveyLayout {
            return delegate
        } else if collectionView == nil {
            assertionFailure("No collection view.")
        } else if collectionView?.delegate == nil {
            assertionFailure("No collection view delegate.")
        } else {
            assertionFailure("Collection view delegate does not conform to UICollectionViewDelegateSurveyLayout")
        }
    }
    
    private func itemTypeForIndexPath(indexPath: NSIndexPath) -> ItemType {
        return ItemType(rawValue: collectionViewDelegate.collectionView(collectionView, layout: self, itemTypeForIndexPath: indexPath))!
    }
    
    private func sizeForItemLabelWithWidth(labelWidth:CGFloat, indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(labelWidth, collectionViewDelegate.collectionView(collectionView, layout: self, heightForItemLabelWithWidth: labelWidth, atIndexPath: indexPath))
    }
    
    private func sizeForSectionHeadingWithWidth(labelWidth:CGFloat, indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(labelWidth, collectionViewDelegate.collectionView(collectionView, layout: self, heightForSectionHeadingWithWidth: labelWidth, atIndexPath: indexPath))
    }
    
    // MARK: - Layout methods
    
    var lines:[(CGRect, [UICollectionViewLayoutAttributes])] = []
    
    override func prepareLayout() {
        beginPreparingLayout()
        lines.removeAll(keepCapacity: true)
        
        let collectionViewBounds = collectionView!.bounds
        
        let width = round(fmin(CGRectGetWidth(collectionViewBounds) - 2 * margin, maxWidth))
        let xOffset:CGFloat = round(CGRectGetMidX(collectionViewBounds) - width / 2)
        var yOffset:CGFloat = margin
        
        var line:[UICollectionViewLayoutAttributes] = []
        var totalRect = CGRectNull
        
        func addToLine(attributes:UICollectionViewLayoutAttributes) {
            line.append(attributes)
            totalRect = CGRectUnion(totalRect, attributes.frame)
        }
        
        func commitLine() -> CGRect {
            if line.count > 0 {
                let pair = (totalRect, line)
                lines.append(pair)
                line.removeAll(keepCapacity: true)
            }
            
            let retValue = totalRect
            totalRect = CGRectNull
            return retValue
        }
        
        for section in 0 ..< self.collectionView!.numberOfSections() {
            
            for item in 0 ..< self.collectionView!.numberOfItemsInSection(section) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let cellAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                cellAttributes.frame = CGRectMake(xOffset, yOffset, width, 30)
                setLayoutAttributes(cellAttributes, forItemAtIndexPath: indexPath)
                addToLine(cellAttributes)
                
                yOffset = CGRectGetMaxY(commitLine()) + itemSpacing
            }
        }
        
        _collectionViewContentSize = CGSizeMake(width, yOffset - itemSpacing + margin)
        
        endPreparingLayout()
    }
    
    private var _collectionViewContentSize:CGSize = CGSizeZero
    override func collectionViewContentSize() -> CGSize {
        return _collectionViewContentSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var output:[UICollectionViewLayoutAttributes] = []
        for (lineRect, attributes) in lines {
            if CGRectIntersectsRect(lineRect, rect) {
                output += attributes
            }
        }
        return output
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return fabs(CGRectGetWidth(newBounds) - CGRectGetWidth(collectionView!.bounds)) > 1
    }
}

@objc protocol UICollectionViewDelegateSurveyLayout : UICollectionViewDelegateSEUILayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, itemTypeForIndexPath indexPath: NSIndexPath!) -> String /* Cannot pass item type to @objc protocol */
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForItemLabelWithWidth labelWidth:CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForSectionHeadingWithWidth labelWidth:CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat
}
