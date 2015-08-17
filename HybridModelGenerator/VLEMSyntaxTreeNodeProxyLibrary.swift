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

struct VLEMParameterWrapper {
    var value:String = "0.0"
    var comment:String = "default_comment"
}

class VLEMSyntaxTreeNodeProxyLibrary: NSObject {
}


final class VLEMMetabolicRateControlRuleProxyNode:VLEMProxyNode {
    
    private var syntax_tree_component:SyntaxTreeComponent
    var token_type:TokenType = TokenType.NULL
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
        
        // check to see if this is a composite, if so, then is it an action, if yes then grab the token type
        if let _parent_node = node as? SyntaxTreeComposite where (_parent_node.tokenType == TokenType.ACTIVATE ||
            _parent_node.tokenType == TokenType.ACTIVATES ||
            _parent_node.tokenType == TokenType.INHIBIT ||
            _parent_node.tokenType == TokenType.INHIBITS){
            
            // set the tokenType -
            token_type = node.tokenType
        }
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
    
    
    
    var control_parameter_array:[VLEMParameterWrapper]? {
        
        get {
         
            // ok, I need to figure out the control parameter array -
            if let _control_subtree = syntax_tree_component as? SyntaxTreeComposite {
                
                if let _relationship_node = _control_subtree.children_array[0] as? SyntaxTreeComposite {
                    
                    // Get the effector array -
                    let _effector_node_array = _relationship_node.children_array
                    
                    // Different array *depending* upon OR -or- AND
                    if (_relationship_node.tokenType == TokenType.OR){
                        
                        // effector array -
                        var local_array = [VLEMParameterWrapper]()
                        for _effector_node in _effector_node_array {
                            
                            // create gain wrapper -
                            var gain_wrapper = VLEMParameterWrapper()
                            gain_wrapper.value = "0.1"
                            gain_wrapper.comment = "OR: Gain -> Actor: \(_effector_node.lexeme!)"
                            
                            // create order wrapper -
                            var order_wrapper = VLEMParameterWrapper()
                            order_wrapper.value = "1.0"
                            order_wrapper.comment = "OR: Order -> Actor: \(_effector_node.lexeme!)"
                            
                            local_array.append(gain_wrapper)
                            local_array.append(order_wrapper)
                        }
                        
                        return local_array
                    }
                    else if (_relationship_node.tokenType == TokenType.AND){
                        
                        // formulate parameter string ...
                        // we have an AND, which means all the effectors as a single effector -
                        var local_array = [VLEMParameterWrapper]()
                        
                        // create comment -
                        var node_counter = 1
                        var effector_buffer:String = ""
                        for _effector_node in _effector_node_array {
                            
                            
                            if (node_counter%2 == 0){
                                effector_buffer+="*"
                            }
                            
                            effector_buffer+=_effector_node.lexeme!
                            node_counter++
                        }
                        
                        // create gain wrapper -
                        var gain_wrapper = VLEMParameterWrapper()
                        gain_wrapper.value = "0.1"
                        gain_wrapper.comment = "AND: Gain -> Actor: \(effector_buffer)"
                        
                        // create order wrapper -
                        var order_wrapper = VLEMParameterWrapper()
                        order_wrapper.value = "1.0"
                        order_wrapper.comment = "AND: Order -> Actor: \(effector_buffer)"
    
                        local_array.append(gain_wrapper)
                        local_array.append(order_wrapper)
                        
                        return local_array
                    }
                }
            }
            
            
            // default is nil -
            return nil
        }
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        return false
    }
}

final class VLEMMetabolicRateProcessProxyNode:VLEMProxyNode {
    
    private var syntax_tree_component:SyntaxTreeComponent
    var token_type:TokenType = TokenType.CATALYZE
    
    // rate process specific stuff -
    var enzyme:SyntaxTreeComponent?
    var reactants_array:[SyntaxTreeComponent]?
    var products_array:[SyntaxTreeComponent]?
    var rate_index:Int = 0
    
    var default_rate_constant:Double {
        get {
            return 0.1
        }
    }
    
    var default_saturation_constant_array:[Double] {
        get {
            
            // ok, so we need to figure out how big my reactants array is, and then 
            // create a default constant array of the size -
            let number_of_reactants = reactants_array?.count
            
            var tmp_array = [Double]()
            for var index = 0;index<number_of_reactants; index++ {
                tmp_array.append(1.0)
            }
            
            return tmp_array
        }
    }
    
    var default_reaction_comment_string:String {
        
        get {
            
            let reactant_buffer = "reactants"
            let product_buffer = "products"
            let enzyme_name = self.default_enzyme_symbol
            
            
            
            let reaction_string = reactant_buffer+" -- "+enzyme_name+" --> "+product_buffer
            return reaction_string
        }
    }
    
    var default_enzyme_symbol:String {
        get {
            if let _name = enzyme?.lexeme {
                return _name
            }
            else {
                return VLEMConstants.MISSING_ENZYME_SYMBOL
            }
        }
    }
    
    var rate_law_string:String {
        
        get {
         
            // Rate buffer -
            var rate_buffer = ""
            
            // Enzyme name -
            let enzyme_name = self.default_enzyme_symbol
            
            // Rate constant string -
            let rate_constant_string = "k_\(self.rate_index)_\(enzyme_name)*"
            
            // Saturation term string -
            var saturation_term = ""
            
            if let _reactants_array = reactants_array {
                
                for _reactant_proxy in _reactants_array {
                 
                    // what is the reactant symbol?
                    let reactant_symbol = _reactant_proxy.lexeme!
                    saturation_term+="*(\(reactant_symbol)/(K_\(self.rate_index)_\(reactant_symbol) + \(reactant_symbol)))"
                }
            }
            
            // Formulate the rate -
            rate_buffer+=rate_constant_string
            rate_buffer+=enzyme_name
            rate_buffer+=saturation_term
            
            // return the reaction buffer -
            return rate_buffer
        }
    }
    
    var rate_constant_string:String {
        get {
            
            // Enzyme name -
            let enzyme_name = self.default_enzyme_symbol
            
            // Rate constant string -
            let rate_constant = "k_\(self.rate_index)_\(enzyme_name)"
            return rate_constant
        }
    }
    
    var saturation_constant_string:[String] {
        
        get {
         
            var saturation_constant_array = [String]()
            
            if let _reactants_array = reactants_array {
                
                for _reactant_proxy in _reactants_array {
                    
                    // what is the reactant symbol?
                    let reactant_symbol = _reactant_proxy.lexeme!
                    saturation_constant_array.append("K_\(self.rate_index)_\(reactant_symbol)")
                }
            }
            
            return saturation_constant_array
        }
    }
    
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
    }
    
    
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        if let _test_node = node as? VLEMSystemTransferProcessProxyNode {
            
            if (token_type == _test_node.token_type){
                
                if (_test_node.syntax_tree_component.lexeme == self.syntax_tree_component.lexeme){
                    return true
                }
            }
        }
        return false
    }
}

final class VLEMSystemTransferProcessProxyNode:VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    var token_type:TokenType = TokenType.SYSTEM
    
    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        if let _test_node = node as? VLEMSystemTransferProcessProxyNode {
            
            if (token_type == _test_node.token_type){
                
                if (_test_node.syntax_tree_component.lexeme == self.syntax_tree_component.lexeme){
                    return true
                }
            }
        }
        return false
    }
}

final class VLEMBasalGeneExpressionKineticsFunctionProxy:VLEMProxyNode {

    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    var token_type:TokenType = TokenType.MESSENGER_RNA
    var gene_index:Int = 1
    var parameter_array_base_index:Int = 0
    var parameter_index:Int {
        get {
            return 3*gene_index - 1 + parameter_array_base_index
        }
    }

    // initialize -
    init(node:SyntaxTreeComponent){
        self.syntax_tree_component = node
    }
    
    func isEqualToProxyNode(node:VLEMProxyNode) -> Bool {
        
        if let _test_node = node as? VLEMBasalGeneExpressionKineticsFunctionProxy {
            
            if (token_type == _test_node.token_type){
                
                if (_test_node.syntax_tree_component.lexeme == self.syntax_tree_component.lexeme){
                    return true
                }
            }
        }
        return false
    }
}

final class VLEMControlRelationshipProxy:VLEMProxyNode {
    
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

final class VLEMMessengerRNADegradationKineticsFunctionProxy: VLEMProxyNode {
    
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

final class VLEMProteinTranslationKineticsFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    private var token_type:TokenType
    var parameter_array_base_index:Int = 0
    
    var protein_index:Int = 1
    var parameter_index:Int {
        get {
            
            let tmp = 2*protein_index + 3*parameter_array_base_index - 1
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

final class VLEMProteinDegradationKineticsFunctionProxy: VLEMProxyNode {
    
    // Declarations -
    private var syntax_tree_component:SyntaxTreeComponent
    private var token_type:TokenType
    var parameter_array_base_index:Int = 0
    
    var protein_index:Int = 1
    var parameter_index:Int {
        get {
            
            let tmp = 2*protein_index + 3*parameter_array_base_index
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


final class VLEMGeneExpressionKineticsFunctionProxy: VLEMProxyNode {
    
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

final class VLEMGeneExpressionControlTransferFunctionProxy: VLEMProxyNode {
    
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

final class VLEMGeneExpressionControlParameterProxy: VLEMProxyNode {
    
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

final class VLEMGeneExpressionRateProcessProxy: VLEMProxyNode {
    
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

func ==(lhs: VLEMSpeciesProxy, rhs: VLEMSpeciesProxy) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

final class VLEMSpeciesProxy:VLEMProxyNode,Hashable {
    
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
    
    var hashValue : Int {
        get {
            return (state_symbol_string?.hashValue)!
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


