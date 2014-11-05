//
//  CheckboxCell.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class CheckboxCell: UICollectionViewCell, ItemHolder {

    @IBOutlet weak var `switch`: UISwitch!
    
    @IBAction func valueChanged(sender: UISwitch) {
        item.textValue = sender.on ? "true" : "false"
    }
    
    var item:SurveyItem! {
        didSet {
            `switch`.on = item.textValue == "true"
        }
    }
    
    class var nib:UINib? {
        return UINib(nibName: "CheckboxCell", bundle: nil)
    }
}
