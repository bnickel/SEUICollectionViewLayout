//
//  SurveyItem.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

private var SurveyItemContext = 0

enum ItemType: String {
    case Checkbox = "checkbox"
    case Text = "text"
    case BigText = "big-text"
}

class SurveyItem: NSObject {
    
    
    let identifier:String
    let label:String
    let type:ItemType
    let indent:Int
    dynamic var textValue:String = ""
    dynamic var hidden:Bool = false
    
    private let dependencies:[String:String]
    private var observedItems:[SurveyItem] = []
    
    init(identifier:String, label:String, type:ItemType = .Text, indent:Int = 0, dependencies:[String:String] = [:]) {
        self.identifier = identifier
        self.label = label
        self.type = type
        self.indent = indent
        self.dependencies = dependencies
        super.init()
    }
    
    func startObservingWithObservables(observables:[String:SurveyItem]) {
        
        for (identifier, value) in dependencies {
            if let item = observables[identifier] {
                item.addObserver(self, forKeyPath: "textValue", options: nil, context: &SurveyItemContext)
                observedItems.append(item)
                if value != item.textValue {
                    hidden = true
                }
            }
        }
    }
    
    func stopObserving() {
        for item in observedItems {
            item.removeObserver(self, forKeyPath: "textValue", context: &SurveyItemContext)
        }
        observedItems.removeAll(keepCapacity: true)
        hidden = false
    }
    
    deinit {
        stopObserving()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &SurveyItemContext {
            
            let item = object as SurveyItem
            if item.textValue != dependencies[item.identifier]! {
                hidden = true
                return
            }
            
            for item in observedItems {
                if item.textValue != dependencies[item.identifier]! {
                    hidden = true
                    return
                }
            }
            
            hidden = false
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - JSON Initialization
    
    private class func parseDependencies(items:AnyObject?) -> [String:String] {
        
        var output:[String:String] = [:]
        
        func parseItem(item:String) {
            if let range = item.rangeOfString("=", options: nil, range: nil, locale: nil) {
                output.updateValue(item.substringFromIndex(range.endIndex), forKey: item.substringToIndex(range.startIndex))
            }
        }
        
        if let item = items as? String {
            parseItem(item)
        } else if let itemsAsArray = items as? [String] {
            for item in itemsAsArray {
                parseItem(item)
            }
        }
        
        return output
    }
    
    convenience init?(dictionary:NSDictionary) {
        
        if let identifier = dictionary["id"] as? String {
            if let label = dictionary["label"] as? String {
                
                let type = ItemType(rawValue: (dictionary["type"] as? String) ?? "") ?? .Text
                let indent = (dictionary["indent"] as? Int) ?? 0
                self.init(identifier:identifier, label:label, type:type, indent:indent, dependencies:SurveyItem.parseDependencies(dictionary["show-if"]))
                return
            }
        }
        
        self.init(identifier:"", label:"")
        return nil
    }
    
    
}
