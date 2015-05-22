//
//  VLEMSentenceWrapper.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class VLEMSentenceWrapper: NSObject {
    
    // declarations -
    var line_number:Int = 0
    var sentence:String

    init(sentence:String,lineNumber:Int) {
        
        line_number = lineNumber
        self.sentence = sentence
    }
    
}
