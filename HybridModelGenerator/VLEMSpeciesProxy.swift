//
//  VLEMSpeciesProxy.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class VLEMSpeciesProxy: NSObject {
    
    // Declarations -
    var syntax_tree_node:SyntaxTreeComponent?
    var state_symbol_string:String?
    var default_value:Double?
    var token_type:TokenType?
    
    // init -
    init (node:SyntaxTreeComponent){
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL){
            
            // Grab the node -
            self.syntax_tree_node = node
            
            if let symbol_lexeme = node.lexeme {
                self.state_symbol_string = symbol_lexeme
            }
        }
    }
}
