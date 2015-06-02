//
//  Symbol.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class Symbol: Composite {

    // declarations -
    var tokenType:TokenType
    var lexeme:String
    
    init(_ tokenType:TokenType,lexeme:String){
        
        // grab the kids -
        self.lexeme = lexeme
        self.tokenType = tokenType
    }
    
    
}
