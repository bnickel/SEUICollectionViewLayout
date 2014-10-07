//
//  TextCell.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/7/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class TextCell: UICollectionViewCell, ItemHolder, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    func textFieldDidEndEditing(textField: UITextField) {
        item.textValue = textField.text
    }
    
    var item:SurveyItem! {
        didSet {
            textField.text = item.textValue
        }
    }
    
    class var nib:UINib? {
        return UINib(nibName: "TextCell", bundle: nil)
    }

}
