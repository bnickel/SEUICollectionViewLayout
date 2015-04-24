//
//  HeadingView.swift
//  Code Survey
//
//  Created by Brian Nickel on 11/5/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

private let SizingHeadingView:HeadingView = HeadingView.nib!.instantiateWithOwner(nil, options: nil)[0] as! HeadingView

class HeadingView: UICollectionReusableView {
    
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
        return UINib(nibName: "HeadingView", bundle: nil)
    }
    
    class func heightForText(text:String, width:CGFloat) -> CGFloat {
        SizingHeadingView.label.text = text
        return SizingHeadingView.label.sizeThatFits(CGSizeMake(width, 0)).height + 1
    }
}
