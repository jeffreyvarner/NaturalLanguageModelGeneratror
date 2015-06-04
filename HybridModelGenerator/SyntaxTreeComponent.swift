//
//  SyntaxTreeComponent.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class SyntaxTreeComponent: NSObject {
    
    // declarations -
    var tokenType:TokenType
    var lexeme:String?
    
    init (type:TokenType){
        self.tokenType = type
    }
}
