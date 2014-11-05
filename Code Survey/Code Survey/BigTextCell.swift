//
//  BigTextCell.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/7/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class BigTextCell: UICollectionViewCell, ItemHolder, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
        layer.borderColor = UIColor.grayColor().CGColor
    }
    
    func textViewDidChange(textView: UITextView) {
        item.textValue = textView.text
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        item.textValue = textView.text
    }
    
    var item:SurveyItem! {
        didSet {
            textView.text = item.textValue
        }
    }
    
    class var nib:UINib? {
        return UINib(nibName: "BigTextCell", bundle: nil)
    }

}
