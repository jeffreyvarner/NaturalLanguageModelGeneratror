//
//  VLEMGeneExpressionProcessRateProxy.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/6/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class VLEMGeneExpressionRateProcessProxy: NSObject {

    // Declarations -
    var gene_expression_tree:SyntaxTreeComposite?
    var token_type:TokenType?
    
    var default_value:Double = 0.0
    
    // initialize -
    init(node:SyntaxTreeComposite){
        
        self.gene_expression_tree = node
        self.token_type = node.tokenType
    }
}
