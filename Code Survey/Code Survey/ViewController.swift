//
//  ViewController.swift
//  Code Survey
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var survey:Survey!

    override func viewDidLoad() {
        super.viewDidLoad()
        survey = Survey(URL: NSBundle.mainBundle().URLForResource("survey", withExtension: "json")!)
        survey.trackHiding = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

