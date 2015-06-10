//
//  VLEMGeneExpressionControlParameterProxy.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/9/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum GeneExpressionParameterType {
    
    case EXPRESSION_GAIN
    case EXPRESSION_ORDER
    case NULL
}

class VLEMGeneExpressionControlParameterProxy: NSObject {

    // Declarations -
    var gene_expression_control_tree:SyntaxTreeComponent
    var gene_expression_parameter_type:GeneExpressionParameterType = GeneExpressionParameterType.NULL
    var proxy_description:String?
    var default_value:Double = 0.0
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.gene_expression_control_tree = node
    }
}
