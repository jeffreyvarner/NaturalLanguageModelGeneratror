//
//  Sentence.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class Sentence: Composite {

    // declarations -
    var action:Composite?
    
    init(actionObject:Action){
        self.action = actionObject
    }
    
}
