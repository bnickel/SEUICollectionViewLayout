//
//  Survey.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class Survey: NSObject {
    
    let sections:[SurveySection]
    
    init(sections:[SurveySection]) {
        self.sections = sections
    }
    
    deinit {
        trackHiding = false
    }
    
    convenience init?(URL:NSURL) {
        if let data = NSData(contentsOfURL: URL) {
            if let items = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [NSDictionary] {
                self.init(sections:map(items, { SurveySection(dictionary: $0) }))
                return
            }
        }
        
        self.init(sections:[])
        return nil
    }
    
    var trackHiding:Bool = false {
        didSet {
            
            if trackHiding {
                
                var observables = [String:SurveyItem]()
                
                for section in sections {
                    for item in section.items {
                        observables.updateValue(item, forKey: item.identifier)
                    }
                }
                
                for section in sections {
                    for item in section.items {
                        item.startObservingWithObservables(observables)
                    }
                }
                
            } else {
                for section in sections {
                    for item in section.items {
                        item.stopObserving()
                    }
                }
            }
        }
    }
}
