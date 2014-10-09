//
//  LabelView.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/8/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

private let SizingLabelView:LabelView = LabelView.nib!.instantiateWithOwner(nil, options: nil)[0] as LabelView

class LabelView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!
    
    override var bounds:CGRect {
        didSet {
            label?.preferredMaxLayoutWidth = CGRectGetWidth(bounds)
        }
    }
    
    override var frame:CGRect {
        didSet {
            label?.preferredMaxLayoutWidth = CGRectGetWidth(frame)
        }
    }
    
    var text:String {
        get {
            return label.text ?? ""
        }
        
        set(value) {
            label.text = value
        }
    }
    
    class var nib:UINib? {
        return UINib(nibName: "LabelView", bundle: nil)
    }
    
    class func heightForText(text:String, width:CGFloat) -> CGFloat {
        SizingLabelView.label.text = text
        return SizingLabelView.label.sizeThatFits(CGSizeMake(width, 0)).height
    }
}
