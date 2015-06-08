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
    var gene_expression_tree:SyntaxTreeComponent?
    var token_type:TokenType?
    var lexeme:String?
    var rate_description:String?
    var default_value:Double = 0.0
    
    // initialize -
    init(node:SyntaxTreeComponent){
        
        self.gene_expression_tree = node
        self.token_type = node.tokenType
    }
}
