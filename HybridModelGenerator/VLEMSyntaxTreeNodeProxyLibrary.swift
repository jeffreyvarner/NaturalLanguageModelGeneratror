//
//  VLEMSyntaxTreeNodeProxyLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/12/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum GeneExpressionParameterType {
    
    case EXPRESSION_GAIN
    case EXPRESSION_ORDER
    case NULL
}

protocol VLEMProxyNode {
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool
}

class VLEMSyntaxTreeNodeProxyLibrary: NSObject {
}

class VLEMControlRelationshipProxy:VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    var token_type:TokenType
    var target_index:Int = 1
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        if let _test_node = node as? VLEMControlRelationshipProxy {
            
            if (token_type == _test_node.token_type){
                return true
            }
        }
        
        return false
    }
    
    var effector_lexeme_array:[String]? {
        
        get {
         
            if let _control_subtree = syntax_tree_component as? SyntaxTreeComposite {
                
                if let _relationship_node = _control_subtree.children_array[0] as? SyntaxTreeComposite {
                    
                    // Get the effector array -
                    let _effector_node_array = _relationship_node.children_array
                    
                    // Different array *depending* upon OR -or- AND
                    if (_relationship_node.tokenType == TokenType.OR){
                     
                        // effector array -
                        var local_array = [String]()
                        for effector_node:SyntaxTreeComponent in _effector_node_array {
                            local_array.append(effector_node.lexeme!)
                        }
                        
                        return local_array
                    }
                    else if (_relationship_node.tokenType == TokenType.AND){
                        
                        var local_buffer = "1.0"
                        for effector_node:SyntaxTreeComponent in _effector_node_array {
                            local_buffer+="*\(effector_node.lexeme!)"
                        }
                        
                        return [local_buffer]
                    }
                }
            }
            
            return nil
        }
    }
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
        self.token_type = node.tokenType
    }
}

class VLEMMessengerRNADegradationKineticsFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    private var token_type:TokenType
    
    var mRNA_index:Int = 1
    var parameter_array_base_index:Int = 0
    
    var parameter_index:Int {
        get {
            return 3*mRNA_index + parameter_array_base_index
        }
    }
    
    var proxy_symbol:String {
        get {
            if let _lexeme = syntax_tree_component.lexeme {
                return _lexeme
            }
            else {
                return "magic_white_powder"
            }
        }
    }
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
        self.token_type = node.tokenType
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        // check the class -
        if let _test_node = node as? VLEMMessengerRNADegradationKineticsFunctionProxy {
            
            // check the token type -
            if (_test_node.token_type == token_type){
             
                // check the lexeme -
                if (syntax_tree_component.lexeme == _test_node.syntax_tree_component.lexeme){
                 
                    return true
                    
                }
            }
        }
        
        return false
    }
}

class VLEMProteinTranslationKineticsFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    private var token_type:TokenType
    var parameter_array_base_index:Int = 0
    
    var protein_index:Int = 1
    var parameter_index:Int {
        get {
            
            var tmp = 2*protein_index + 3*parameter_array_base_index - 1
            return tmp
        }
    }
    
    var proxy_symbol:String {
        get {
            if let _lexeme = syntax_tree_component.lexeme {
                return _lexeme
            }
            else {
                return "magic_white_powder"
            }
        }
    }
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
        self.token_type = node.tokenType
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        // check the class -
        if let _test_node = node as? VLEMProteinTranslationKineticsFunctionProxy {
            
            // check the token type -
            if (_test_node.token_type == token_type){
                
                // check the lexeme -
                if (syntax_tree_component.lexeme == _test_node.syntax_tree_component.lexeme){
                    
                    return true
                    
                }
            }
        }
        
        return false
    }
}

class VLEMProteinDegradationKineticsFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    private var token_type:TokenType
    var parameter_array_base_index:Int = 0
    
    var protein_index:Int = 1
    var parameter_index:Int {
        get {
            
            var tmp = 2*protein_index + 3*parameter_array_base_index
            return tmp
        }
    }
    
    var proxy_symbol:String {
        get {
            if let _lexeme = syntax_tree_component.lexeme {
                return _lexeme
            }
            else {
                return "magic_white_powder"
            }
        }
    }
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
        self.token_type = node.tokenType
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        // check the class -
        if let _test_node = node as? VLEMProteinDegradationKineticsFunctionProxy {
            
            // check the token type -
            if (_test_node.token_type == token_type){
                
                // check the lexeme -
                if (syntax_tree_component.lexeme == _test_node.syntax_tree_component.lexeme){
                    
                    return true
                    
                }
            }
        }
        
        return false
    }
}


class VLEMGeneExpressionKineticsFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    private var token_type:TokenType
    
    var gene_index:Int = 1
    var parameter_array_base_index:Int = 0
    
    var parameter_index:Int {
        get {
            return 3*gene_index - 2 + parameter_array_base_index
        }
    }
    
    var gene_symbol:String {
        get {
            if let _lexeme = syntax_tree_component.lexeme {
                return _lexeme
            }
            else {
                return "magic_white_powder"
            }
        }
    }
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
        self.token_type = node.tokenType
    }
    
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        // check the class -
        if let _test_node = node as? VLEMGeneExpressionKineticsFunctionProxy {
            
            // check the token type -
            if (_test_node.token_type == token_type){
                
                // check the lexeme -
                if (syntax_tree_component.lexeme == _test_node.syntax_tree_component.lexeme){
                    
                    return true
                    
                }
            }
        }
        
        return false
    }
}

class VLEMGeneExpressionControlTransferFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    var control_token_type:TokenType = TokenType.NULL
    var syntax_tree_component:SyntaxTreeComponent
    var target_node:SyntaxTreeComponent?
    
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        return false
    }
}

class VLEMGeneExpressionControlParameterProxy: VLEMProxyNode {
    
    // Declarations -
    var gene_expression_control_tree:SyntaxTreeComponent
    var gene_expression_parameter_type:GeneExpressionParameterType = GeneExpressionParameterType.NULL
    var proxy_description:String?
    var default_value:Double = 0.0
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.gene_expression_control_tree = node
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        return false
    }
}

class VLEMGeneExpressionRateProcessProxy: VLEMProxyNode {
    
    // Declarations -
    var gene_expression_tree:SyntaxTreeComponent?
    var token_type:TokenType?
    var lexeme:String?
    var rate_description:String?
    var default_value:Double = 0.0
    
    var target_node:SyntaxTreeComponent?
    
    // initialize -
    init(node:SyntaxTreeComponent){
        
        self.gene_expression_tree = node
        self.token_type = node.tokenType
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        return false
    }
}

class VLEMSpeciesProxy: VLEMProxyNode {
    
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
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        // check the class -
        if let _test_node = node as? VLEMSpeciesProxy, let _syntax_tree_component = syntax_tree_node {
            
            // check the token type -
            if (_test_node.token_type == token_type){
                
                // check the lexeme -
                if (_syntax_tree_component.lexeme == _test_node.syntax_tree_node!.lexeme!){
                    
                    return true
                    
                }
            }
        }
        
        return false
    }
}


