//
//  ViewController.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

@objc protocol ItemHolder {
    var item:SurveyItem! {get set}
}

class SurveyViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateSurveyLayout {
    
    var survey:Survey!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var collectionViewTopConstraint:NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        survey = Survey(URL: NSBundle.mainBundle().URLForResource("survey", withExtension: "json")!)
        survey.trackHiding = true
        
        let layout = collectionView.collectionViewLayout as! SurveyCollectionViewLayout
        layout.checkboxSize = CheckboxCell.preferredSize
        layout.textSize = CGSize(width: 200, height: TextCell.preferredHeight)
        layout.bigTextHeight = 100
        layout.animateBoundsChanges = true
        
        survey.hidingChangedCallback = {
            [unowned self] in
            self.collectionView.performBatchUpdates({ () -> Void in
                layout.invalidateLayout()
            }, completion: nil)
        }
        
        var perspective = CATransform3DIdentity
        perspective.m34 = 1 / -500
        
        collectionView.registerNib(CheckboxCell.nib, forCellWithReuseIdentifier: ItemType.Checkbox.rawValue)
        collectionView.registerNib(BigTextCell.nib, forCellWithReuseIdentifier: ItemType.BigText.rawValue)
        collectionView.registerNib(TextCell.nib, forCellWithReuseIdentifier: ItemType.Text.rawValue)
        collectionView.registerNib(LabelView.nib, forSupplementaryViewOfKind: SurveyCollectionViewItemLabel, withReuseIdentifier: SurveyCollectionViewItemLabel)
        collectionView.registerNib(HeadingView.nib, forSupplementaryViewOfKind: SurveyCollectionViewSectionHeader, withReuseIdentifier: SurveyCollectionViewSectionHeader)
        collectionView.layer.sublayerTransform = perspective
        
        fixAnimations(top:150, bottom:300)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func surveySection(section:Int) -> SurveySection {
        return survey.sections[section]
    }
    
    func surveyItem(indexPath:NSIndexPath) -> SurveyItem {
        return survey.sections[indexPath.section].items[indexPath.item]
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return survey.sections.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveySection(section).items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let item = surveyItem(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.type.rawValue, forIndexPath: indexPath) as! UICollectionViewCell
        
        (cell as! ItemHolder).item = surveyItem(indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kind, forIndexPath: indexPath) as! UICollectionReusableView
        
        switch kind {
        case SurveyCollectionViewItemLabel:
            (view as! LabelView).text = surveyItem(indexPath).label
        case SurveyCollectionViewSectionHeader:
            (view as! HeadingView).text = surveySection(indexPath.section).heading
        default: assertionFailure("Unexpected supplementary element kind: \(kind)")
        }
        return view
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SEUICollectionViewLayout!, uniqueIdentifierForSection section: UInt) -> NSCopying! {
        return section
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SEUICollectionViewLayout!, uniqueIdentifierForItemAtIndexPath indexPath: NSIndexPath!) -> NSCopying! {
        return indexPath
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForItemLabelWithWidth labelWidth: CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return LabelView.heightForText(surveyItem(indexPath).label, width: labelWidth)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForSectionHeadingWithWidth labelWidth: CGFloat, section: Int) -> CGFloat {
        return HeadingView.heightForText(surveySection(section).heading, width: labelWidth)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, itemTypeForIndexPath indexPath: NSIndexPath!) -> String {
        return surveyItem(indexPath).type.rawValue
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, indentLevelForIndexPath indexPath: NSIndexPath!) -> Int {
        return surveyItem(indexPath).indent
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, shouldHideItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return surveyItem(indexPath).hidden
    }
    
    func fixAnimations(#top:CGFloat, bottom:CGFloat) {
        collectionViewTopConstraint.constant = -top
        collectionViewBottomConstraint.constant = -bottom
        
        var contentInset = collectionView.contentInset
        contentInset.top += top
        contentInset.bottom += bottom
        collectionView.contentInset = contentInset
        
        var indicatorInset = collectionView.scrollIndicatorInsets
        indicatorInset.top += top
        indicatorInset.bottom += bottom
        collectionView.scrollIndicatorInsets = indicatorInset
    }
    
    var keyboardInsetAdjustment:CGFloat = 0 {
        didSet(oldValue) {
            let difference = keyboardInsetAdjustment - oldValue
            
            var contentInset = collectionView.contentInset
            contentInset.bottom += difference
            collectionView.contentInset = contentInset
            
            var indicatorInset = collectionView.scrollIndicatorInsets
            indicatorInset.bottom += difference
            collectionView.scrollIndicatorInsets = indicatorInset
        }
    }
    
    func keyboardWillShow(notification:NSNotification) {
        if let size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size {
            keyboardInsetAdjustment = size.height
            
            let activeCells = collectionView.visibleCells().filter({ cell in
                
                if let textCell = cell as? TextCell {
                    if textCell.textField.isFirstResponder() {
                        return true
                    }
                } else if let bigTextCell = cell as? BigTextCell {
                    if bigTextCell.textView.isFirstResponder() {
                        return true
                    }
                }
                
                return false
            })
            
            if let cell = activeCells.first as? UICollectionViewCell {
                collectionView.scrollRectToVisible(cell.frame, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        keyboardInsetAdjustment = 0
    }
}

