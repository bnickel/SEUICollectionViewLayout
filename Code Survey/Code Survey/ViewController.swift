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

class ViewController: UICollectionViewController, UICollectionViewDelegateSurveyLayout {
    
    var survey:Survey!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        survey = Survey(URL: NSBundle.mainBundle().URLForResource("survey", withExtension: "json")!)
        survey.trackHiding = true
        
        let layout = collectionViewLayout as SurveyCollectionViewLayout
        layout.checkboxSize = CheckboxCell.preferredSize
        layout.textSize = CGSize(width: 200, height: TextCell.preferredHeight)
        layout.bigTextHeight = 100
        layout.animateBoundsChanges = true
        
        collectionView.registerNib(CheckboxCell.nib, forCellWithReuseIdentifier: ItemType.Checkbox.rawValue)
        collectionView.registerNib(BigTextCell.nib, forCellWithReuseIdentifier: ItemType.BigText.rawValue)
        collectionView.registerNib(TextCell.nib, forCellWithReuseIdentifier: ItemType.Text.rawValue)
    }
    
    func surveySection(section:Int) -> SurveySection {
        return survey.sections[section]
    }
    
    func surveyItem(indexPath:NSIndexPath) -> SurveyItem {
        return survey.sections[indexPath.section].items[indexPath.item]
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return survey.sections.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveySection(section).items.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let item = surveyItem(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(item.type.rawValue, forIndexPath: indexPath) as UICollectionViewCell
        
        (cell as ItemHolder).item = surveyItem(indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SEUICollectionViewLayout!, uniqueIdentifierForSection section: UInt) -> NSCopying! {
        return section
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SEUICollectionViewLayout!, uniqueIdentifierForItemAtIndexPath indexPath: NSIndexPath!) -> NSCopying! {
        return indexPath
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForItemLabelWithWidth labelWidth: CGFloat, atIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, heightForSectionHeadingWithWidth labelWidth: CGFloat, section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: SurveyCollectionViewLayout!, itemTypeForIndexPath indexPath: NSIndexPath!) -> String {
        return surveyItem(indexPath).type.rawValue
    }
}

