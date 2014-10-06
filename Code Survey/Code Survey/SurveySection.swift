//
//  SurveySection.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class SurveySection: NSObject {
    
    let heading:String
    let items:[SurveyItem]
    
    init(heading:String, items:[SurveyItem]) {
        self.heading = heading
        self.items = items
        super.init()
    }
    
    convenience init(dictionary:NSDictionary) {
        let heading = dictionary["name"] as? String
        var items:[SurveyItem] = []
        if let questions = dictionary["questions"] as? [NSDictionary] {
            items = map(filter(map(questions, { SurveyItem(dictionary:$0) }), { $0 != nil }), { $0! })
        }
        
        self.init(heading:heading ?? "", items:items)
    }
}
