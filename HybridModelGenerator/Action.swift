//
//  Action.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa



class Action: Composite {

    // Declarations -
    var tokenType:TokenType
    var children_array:[Composite]
    
    init(_ tokenType:TokenType,children:Composite...){
        
        // grab the kids -
        self.children_array = children
        self.tokenType = tokenType
    }
    
}
