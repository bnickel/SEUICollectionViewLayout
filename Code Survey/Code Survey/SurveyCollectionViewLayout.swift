//
//  SurveyCollectionViewLayout.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

let SurveyCollectionViewItemLabel = "SurveyCollectionViewItemLabel"
let SurveyCollectionViewSectionHeader = "SurveyCollectionViewSectionHeader"

class SurveyCollectionViewLayout: SEUICollectionViewLayout {
    
    // MARK: - Properties
    
    var checkboxSize:CGSize = CGSizeMake(10, 10) {
        didSet(oldValue) {
            if checkboxSize != oldValue {
                invalidateLayout()
            }
        }
    }
    
    var textSize:CGSize = CGSizeMake(100, 50) {
        didSet(oldValue) {
            if textSize != oldValue {
                invalidateLayout()
            }
        }
    }
    
    var bigTextHeight:CGFloat = 50 {
        didSet(oldValue) {
            if bigTextHeight != oldValue {
                invalidateLayout()
            }
        }
    }
    
    var itemSpacing:CGFloat = 10 {
        didSet(oldValue) {
            if itemSpacing != oldValue {
                invalidateLayout()
            }
        }
    }
    
    var margin:CGFloat = 10 {
        didSet(oldValue) {
            if margin != oldValue {
                invalidateLayout()
            }
        }
    }
    
    var maxWidth:CGFloat = 500 {
        didSet(oldValue) {
            if maxWidth != oldValue {
                invalidateLayout()
            }
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
    
    private func indentLevelForIndexPath(indexPath: NSIndexPath) -> Int {
        return collectionViewDelegate.collectionView(collectionView, layout: self, indentLevelForIndexPath: indexPath)
    }
    
    private func itemTypeForIndexPath(indexPath: NSIndexPath) -> ItemType {
        return ItemType(rawValue: collectionViewDelegate.collectionView(collectionView, layout: self, itemTypeForIndexPath: indexPath))!
    }
    
    private func shouldHideItemAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return collectionViewDelegate.collectionView(collectionView, layout: self, shouldHideItemAtIndexPath: indexPath)
    }
    
    private func sizeForItemLabelWithWidth(labelWidth:CGFloat, indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(labelWidth, collectionViewDelegate.collectionView(collectionView, layout: self, heightForItemLabelWithWidth: labelWidth, atIndexPath: indexPath))
    }
    
    private func sizeForSectionHeadingWithWidth(labelWidth:CGFloat, section: Int) -> CGSize {
        return CGSizeMake(labelWidth, collectionViewDelegate.collectionView(collectionView, layout: self, heightForSectionHeadingWithWidth: labelWidth, section: section))
    }
    
    // MARK: - Layout methods
    
    private var lines:[(CGRect, [UICollectionViewLayoutAttributes])] = []
    
    override func prepareLayout() {
        beginPreparingLayout()
        lines.removeAll(keepCapacity: true)
        
        let collectionViewBounds = collectionView!.bounds
        
        let width = round(fmin(CGRectGetWidth(collectionViewBounds) - 2 * margin, maxWidth))
        let xOffset:CGFloat = round(CGRectGetMidX(collectionViewBounds) - width / 2)
        var yOffset:CGFloat = margin
        var yOffsetHidden:CGFloat = yOffset
        
        func commitAttributes(attributes:[UICollectionViewLayoutAttributes], #hidden: Bool) -> CGRect {
            
            var totalRect = CGRectNull
            for attribute in attributes {
                totalRect = CGRectUnion(totalRect, attribute.frame)
            }
            
            if hidden {
                for attribute in attributes {
                    attribute.alpha = 0
                    attribute.transform3D = CATransform3DMakeTranslation(0, 0, 250)
                }
            }
            
            let pair = (totalRect, attributes)
            lines.append(pair)
            return totalRect
        }
        
        func sideBySideItems(indexPath:NSIndexPath, yOffset:CGFloat, itemSize:CGSize, indentLevel:Int) -> [UICollectionViewLayoutAttributes] {
            
            let indent = CGFloat(indentLevel) * itemSpacing * 2
            let labelSize = sizeForItemLabelWithWidth(width - itemSpacing - itemSize.width - indent, indexPath: indexPath)
            let height = max(itemSize.height, labelSize.height)
            let labelOrigin = CGPoint(x: xOffset + indent, y: yOffset + (height - labelSize.height) / 2)
            let itemOrigin = CGPoint(x: xOffset + width - itemSize.width, y: yOffset + (height - itemSize.height) / 2)
            
            let cellAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            cellAttributes.frame = CGRect(origin: itemOrigin, size: itemSize)
            setLayoutAttributes(cellAttributes, forItemAtIndexPath: indexPath)
            
            let labelAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SurveyCollectionViewItemLabel, withIndexPath: indexPath)
            labelAttributes.frame = CGRect(origin: labelOrigin, size: labelSize)
            setLayoutAttributes(labelAttributes, forSupplementaryViewOfKind: SurveyCollectionViewItemLabel, atIndexPath: indexPath)
            
            return [labelAttributes, cellAttributes]
        }
        
        func stackedItems(indexPath:NSIndexPath, yOffset:CGFloat, height:CGFloat, indentLevel:Int) -> [UICollectionViewLayoutAttributes] {
            
            let indent = CGFloat(indentLevel) * itemSpacing * 2
            
            let labelAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SurveyCollectionViewItemLabel, withIndexPath: indexPath)
            labelAttributes.frame = CGRect(origin: CGPoint(x: xOffset + indent, y: yOffset), size: sizeForItemLabelWithWidth(width - indent, indexPath: indexPath))
            setLayoutAttributes(labelAttributes, forSupplementaryViewOfKind: SurveyCollectionViewItemLabel, atIndexPath: indexPath)
            
            let cellAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            cellAttributes.frame = CGRectMake(xOffset + indent, CGRectGetMaxY(labelAttributes.frame) + itemSpacing / 2, width - indent, height)
            setLayoutAttributes(cellAttributes, forItemAtIndexPath: indexPath)
            
            return [labelAttributes, cellAttributes]
        }
        
        for section in 0 ..< self.collectionView!.numberOfSections() {
            
            let headerIndexPath = NSIndexPath(forItem: NSNotFound, inSection: section)
            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SurveyCollectionViewSectionHeader, withIndexPath: headerIndexPath)
            headerAttributes.frame = CGRect(origin: CGPointMake(xOffset, yOffset), size: sizeForSectionHeadingWithWidth(width, section: section))
            setLayoutAttributes(headerAttributes, forSupplementaryViewOfKind: SurveyCollectionViewSectionHeader, atIndexPath: headerIndexPath)
            let headerRect = commitAttributes([headerAttributes], hidden: false)
            yOffset = CGRectGetMaxY(headerRect) + itemSpacing
            
            for item in 0 ..< self.collectionView!.numberOfItemsInSection(section) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                let indentLevel = indentLevelForIndexPath(indexPath)
                let hidden = shouldHideItemAtIndexPath(indexPath)
                let offset = hidden ? yOffsetHidden : yOffset
                
                var attributes:[UICollectionViewLayoutAttributes]!
                switch itemTypeForIndexPath(indexPath) {
                case .Text:     attributes = sideBySideItems(indexPath, offset, textSize, indentLevel)
                case .Checkbox: attributes = sideBySideItems(indexPath, offset, checkboxSize, indentLevel)
                case .BigText:  attributes = stackedItems(indexPath, offset, bigTextHeight, indentLevel)
                }
                
                let addedRect = commitAttributes(attributes, hidden: hidden)
                yOffsetHidden = CGRectGetMaxY(addedRect) + itemSpacing
                if !hidden {
                    yOffset = yOffsetHidden
                }
            }
        }
        
        _collectionViewContentSize = CGSizeMake(xOffset + width, yOffset - itemSpacing + margin)
        
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
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, indentLevelForIndexPath indexPath: NSIndexPath!) -> Int
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, itemTypeForIndexPath indexPath: NSIndexPath!) -> String /* Cannot pass item type to @objc protocol */
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, shouldHideItemAtIndexPath indexPath: NSIndexPath!) -> Bool
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForItemLabelWithWidth labelWidth:CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForSectionHeadingWithWidth labelWidth:CGFloat, section: Int) -> CGFloat
}
