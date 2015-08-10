//
//  VLEMAbstractSyntaxTreeVistorLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol SyntaxTreeVisitor {
    
    var type_dictionary:Dictionary<String,SyntaxTreeComponent> { get set }
    
    // Require the type dictionary for init ...
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>)
    init()

    func visit(node:SyntaxTreeComponent) -> Void
    func shouldVisit(node:SyntaxTreeComponent) -> Bool
    func getSyntaxTreeVisitorData() -> Any?
    func willVisit(node:SyntaxTreeComponent) -> Void
    func didVisit(node:SyntaxTreeComponent) -> Void
}



final class VLEMAbstractSyntaxTreeVisitorLibrary: NSObject {

    static func classifyTypeOfNode(node:SyntaxTreeComponent,type_dictionary:Dictionary<String,SyntaxTreeComponent>) -> TokenType? {
        
        // What is the lexeme for this node?
        let node_lexeme = node.lexeme
        
        // ok, we need to iterate through my type dictionary, which is key'd by a prefix
        for (key,value) in type_dictionary {
            
            // does the lexeme contain the key?
            if ((node_lexeme?.rangeOfString(key, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil)){
                
                let first_char_key = key[advance(key.startIndex, 0)]
                let first_char_lexeme = node_lexeme![advance(node_lexeme!.startIndex, 0)]
                if (first_char_key == first_char_lexeme){
                    
                    // ok, we have a match, return the token_type
                    return value.tokenType
                }
            }
        }
        
        // default is NULL
        return TokenType.NULL
    }

    static func arrayContainsProxyNode(array:[VLEMProxyNode],node:VLEMProxyNode) -> Bool {
        
        for item in array {
        
            if (node.isEqualToProxyNode(item) == true) {
                return true
            }
        }
        
        return false
    }
    
    static func arrayContainsSyntaxNode(array:[SyntaxTreeComponent],node:SyntaxTreeComponent) -> Bool {
        
        for item in array {
            
            if (item.lexeme == node.lexeme){
                return true
            }
        }
        
        return false
    }
    
    static func removeTypePrefixFromNodeLexeme(node:SyntaxTreeComponent,type_dictionary:Dictionary<String,SyntaxTreeComponent>) -> String? {
        
        // Grab the current node lexeme -
        if let _node_lexeme = node.lexeme {
            
            // ok, we need to iterate through my type dictionary, which is key'd by a prefix
            for (key,_) in type_dictionary {
                
                // does the lexeme contain the key?
                if ((_node_lexeme.rangeOfString(key, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil)){
                    
                    let first_char_key = key[advance(key.startIndex, 0)]
                    let first_char_lexeme = _node_lexeme[advance(_node_lexeme.startIndex, 0)]
                    if (first_char_key == first_char_lexeme){
                        
                        // ok, we have a match!
                        if let prefix_range = _node_lexeme.rangeOfString(key, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) {
                            return _node_lexeme.substringFromIndex(prefix_range.endIndex)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    static func getBiologicalSymbolPrefix(type_dictionary:Dictionary<String,SyntaxTreeComponent>,tokenType:TokenType) -> String? {
        
        // ok, we have a protein, need to create a gene with prefix -
        for (key,value) in type_dictionary {
            
            if value.tokenType == tokenType {
                return key
            }
        }
        return nil
    }
    
    static func isNodeType(node:SyntaxTreeComponent,type_dictionary:Dictionary<String,SyntaxTreeComponent>) -> TokenType? {
        
        // What is the lexeme for this node?
        let node_lexeme = node.lexeme
        
        // ok, we need to iterate through my type dictionary, which is key'd by a prefix
        for (key,value) in type_dictionary {
            
            // does the lexeme contain the key?
            if ((node_lexeme?.rangeOfString(key, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil)){
                
                let first_char_key = key[advance(key.startIndex, 0)]
                let first_char_lexeme = node_lexeme![advance(node_lexeme!.startIndex, 0)]
                if (first_char_key == first_char_lexeme){
                    
                    // ok, we have a match, return the token_type
                    return value.tokenType
                }
            }
        }
        
        // default is NULL
        return TokenType.NULL
    }
}



final class MetabolicControlRulesSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    internal var type_dictionary:Dictionary<String,SyntaxTreeComponent> = Dictionary<String,SyntaxTreeComponent>()
    
    private var control_model_dictionary:Dictionary<String,Array<VLEMMetabolicRateControlRuleProxyNode>> = Dictionary<String,Array<VLEMMetabolicRateControlRuleProxyNode>>()
    private var relationshipProxyArray:[VLEMMetabolicRateControlRuleProxyNode] = [VLEMMetabolicRateControlRuleProxyNode]()
    
    
    // We require the type dictionary -
    init() {
    }
    
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        // ok, we are walking through the tree. 
        // We are only going to look at "action" nodes, and get information from there
        
        // ok, we should have a control node - get the left and right nodes
        if let _control_action_node = node as? SyntaxTreeComposite {
            
            // build a relationship proxy -
            let metabolic_rate_control_proxy = VLEMMetabolicRateControlRuleProxyNode(node: _control_action_node)
        
            // ok, we have the effector and target nodes collection -
            if let target_node_collection = _control_action_node.right_child_node as? SyntaxTreeComposite {
                
                // remove the right child node (this is to make the tree consistent with gene expression) -
                // _control_action_node.removeChildAtIndex(1)
                
                // go through the effector list, map to target action -
                for _child_node in target_node_collection {
                    
                    // do we have this target child in the control table?
                    
                    // build the dictionary -
                    if var _array:[VLEMMetabolicRateControlRuleProxyNode] = control_model_dictionary[_child_node.lexeme!] {
                        
                        // ok, we already have this node in the dictionary
                        _array.append(metabolic_rate_control_proxy)
                        
                        // put array back in dictionary -
                        control_model_dictionary[_child_node.lexeme!] = _array
                    }
                    else {
                        
                        // we do *not* contain the key - store the array
                        control_model_dictionary[_child_node.lexeme!] = [metabolic_rate_control_proxy]
                    }
                }
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // if we have an action node, let's visit ... otherwise no.
        if (node.tokenType == TokenType.ACTIVATE ||
            node.tokenType == TokenType.ACTIVATES ||
            node.tokenType == TokenType.INHIBITS ||
            node.tokenType == TokenType.INHIBIT) {
            
            // ok, we have the correct node type - we can visit
            // this type of node
            return true
        }
        
        // default is no
        return false
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node:SyntaxTreeComponent) -> Void {
        
        // ok, we visted the node. clean up?
        relationshipProxyArray.removeAll(keepCapacity: false)
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        return control_model_dictionary
    }
}

final class MetabolicSaturationKineticsExpressionSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    internal var type_dictionary:Dictionary<String,SyntaxTreeComponent> = Dictionary<String,SyntaxTreeComponent>()
    private var _proxy_array = [VLEMMetabolicRateProcessProxyNode]()
    
    // We require the type dictionary -
    init() {
        
    }
    
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    
        if (node.tokenType == TokenType.CATALYZE){
            
            var _enzyme_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
            var _reactants_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
            
            if let _catalyze_node = node as? SyntaxTreeComposite {
             
                // ok, we have the catalyze composite -
                for _child_node in _catalyze_node {
                    
                    if (_child_node.tokenType == TokenType.GENERATES_SYMBOL){
                        
                        // ok, the *first* child is the reactants -
                        if let _reactants_node = (_child_node as? SyntaxTreeComposite)?.getFirstChildNode() as? SyntaxTreeComposite {
                            
                            for _reactant_node in _reactants_node {
                                _reactants_array.append(_reactant_node)
                            }
                        }
                    }
                    else if (_child_node.tokenType == TokenType.OR){
                        
                        // ok, we have the list of enzymes that can catalyze this rate -
                        if let _or_node = _child_node as? SyntaxTreeComposite {
                            
                            for _enzyme_node in _or_node {
                                _enzyme_array.append(_enzyme_node)
                            }
                        }
                    }
                }
            }
            
            // create proxy - add to the arrays -
            var rate_counter = 1
            for enzyme_node in _enzyme_array {
                
                let _metabolic_proxy = VLEMMetabolicRateProcessProxyNode(node: node)
                _metabolic_proxy.reactants_array = _reactants_array
                _metabolic_proxy.enzyme = enzyme_node
                _metabolic_proxy.rate_index = rate_counter++
                
                // Add the proxy to the array -
                _proxy_array.append(_metabolic_proxy)
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // only visit the system nodes -
        if (node.tokenType == TokenType.CATALYZE){
            return true
        }
        
        return false
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    
        if (node.tokenType == TokenType.CATALYZE){
            
            // Build the enzyme array -
            
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }

    func getSyntaxTreeVisitorData() -> Any? {
        return _proxy_array
    }
}

final class SystemTransferProcessSpeciesSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary:Dictionary<String,SyntaxTreeComponent> = Dictionary<String,SyntaxTreeComponent>()
    private var species_set_from_system = Set<VLEMSpeciesProxy>()
    private var species_set_to_system = Set<VLEMSpeciesProxy>()
    private var transfer_dictionary = Dictionary<TokenType,Set<VLEMSpeciesProxy>>()
    
    // We require the type dictionary -
    init() {
        
    }
    
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        // ok, we should have a system node -
        if let _system_node = node as? SyntaxTreeComposite {
            
            for _child in _system_node {
             
                // ok, we should have 1 child -
                if let _transfer_direction_node = _child as? SyntaxTreeComposite where (_transfer_direction_node.tokenType == TokenType.FROM){
                    // ok, we have a FROM -
                    // grab the kids of this node -
                    for _species_node in _transfer_direction_node {
                        
                        let _species_proxy = VLEMSpeciesProxy(node: _species_node)
                        species_set_from_system.insert(_species_proxy)
                    }
                }
                else if let _transfer_direction_node = _child as? SyntaxTreeComposite where (_transfer_direction_node.tokenType == TokenType.TO){
                    
                    for _species_node in _transfer_direction_node {
                        
                        let _species_proxy = VLEMSpeciesProxy(node: _species_node)
                        species_set_to_system.insert(_species_proxy)
                    }
                }
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // only visit the system nodes -
        if (node.tokenType == TokenType.SYSTEM){
            return true
        }
        
        return false
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }

    func getSyntaxTreeVisitorData() -> Any? {
        
        transfer_dictionary[TokenType.FROM] = species_set_from_system
        transfer_dictionary[TokenType.TO] = species_set_to_system
        
        return transfer_dictionary
    }
}

final class GeneExpressionControlModelSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary:Dictionary<String,SyntaxTreeComponent>
    private var control_model_dictionary:Dictionary<String,Array<VLEMControlRelationshipProxy>> = Dictionary<String,Array<VLEMControlRelationshipProxy>>()
    private var relationshipProxyArray:[VLEMControlRelationshipProxy] = [VLEMControlRelationshipProxy]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        self.type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    
        if (node.tokenType == TokenType.INDUCES || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.INDUCE){
            
            // we are in the control section of the tree ...
            
            // build a relationship proxy -
            let relationship_proxy = VLEMControlRelationshipProxy(node: node)
            
            // store the proxy -
            relationshipProxyArray.append(relationship_proxy)
        }
        else if ((node.tokenType == TokenType.OR || node.tokenType == TokenType.AND) && (node.parent_pointer?.tokenType == TokenType.TRANSCRIPTION)){
            
            // we are in the target section of the tree -
            if let _composite = node as? SyntaxTreeComposite {
                
                for child_node in _composite.children_array {
                
                    // build the dictionary -
                    if var _array:[VLEMControlRelationshipProxy] = control_model_dictionary[child_node.lexeme!] {
                    
                        // ok, we already have this node in the dictionary -
                        for relationship_proxy in relationshipProxyArray {
                            _array.append(relationship_proxy)
                        }
                        
                        // put array back in dictionary -
                        control_model_dictionary[child_node.lexeme!] = _array
                    }
                    else {
                        
                        // we do *not* contain the key - store the array
                        control_model_dictionary[child_node.lexeme!] = relationshipProxyArray
                    }
                }
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    
        // clear out the relation ship array *before* I get to the next tree ..
        if ((node.tokenType == TokenType.OR || node.tokenType == TokenType.AND) && (node.parent_pointer?.tokenType == TokenType.TRANSCRIPTION)){
            if (relationshipProxyArray.count>0){
                relationshipProxyArray.removeAll(keepCapacity:true)
            }
        }
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        return control_model_dictionary
    }
}

final class GeneExpressionControlParameterSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary:Dictionary<String,SyntaxTreeComponent>
    private var control_parameter_proxy_array = [VLEMGeneExpressionControlParameterProxy]()
    private var transcription_root_node:SyntaxTreeComposite?
    private var target_node_array:[SyntaxTreeComponent]?
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        self.type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    
        // declarations -
        let buffer = "->"
        
        if (node.tokenType == TokenType.OR || node.tokenType == TokenType.AND){
            
            if let _parent_pointer = node.parent_pointer {
                
                if (_parent_pointer.tokenType == TokenType.INDUCE || _parent_pointer.tokenType == TokenType.INDUCES ||
                    _parent_pointer.tokenType == TokenType.REPRESSES || _parent_pointer.tokenType == TokenType.REPRESS){
                    
                    if let _local_target_node_array = target_node_array {
                            
                        // create target string -
                        for target_node in _local_target_node_array {
                            
                            // ok, we are on the relationship node ..
                            // Are we an AND -or- an OR?
                            if (node.tokenType == TokenType.OR){
                                
                                // An OR means we'll have seperate transfer functions, each with two parameters ..
                                if let _or_node = node as? SyntaxTreeComposite {
                                    
                                    let number_of_species = _or_node.numberOfChildren()
                                    for var index = 0;index<number_of_species;index++ {
                                        
                                        // Create a parameter node, one alpha and one beta node per child
                                        let _child_node = _or_node.getChildAtIndex(index)
                                        
                                        // Alpha node (gain)
                                        let alpha_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                                        alpha_node.default_value = 0.1
                                        alpha_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_GAIN
                                        alpha_node.proxy_description = "Gain -> Actor: \(_child_node!.lexeme!) \(buffer) \(target_node.lexeme!)"
                                        
                                        // Beta node (order)
                                        let beta_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                                        beta_node.default_value = 1.0
                                        beta_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_ORDER
                                        beta_node.proxy_description = "Order -> Actor: \(_child_node!.lexeme!) \(buffer) \(target_node.lexeme!)"
                                        
                                        // grab for later -
                                        control_parameter_proxy_array.append(alpha_node)
                                        control_parameter_proxy_array.append(beta_node)
                                    }
                                }
                            }
                            else if (node.tokenType == TokenType.AND){
                                
                                // Get the and node -
                                if let _and_node = node as? SyntaxTreeComposite {
                                    
                                    var actor_description = ""
                                    let number_of_species = _and_node.numberOfChildren()
                                    for var index = 0;index<number_of_species;index++ {
                                        
                                        // Create a parameter node, one alpha and one beta node per child
                                        let _child_node = _and_node.getChildAtIndex(index)
                                        actor_description+=_child_node!.lexeme!
                                        
                                        if (index < number_of_species - 1)
                                        {
                                            actor_description+="*"
                                        }
                                    }
                                    
                                    // This is easy - we create a *single* alpha and beta parameter
                                    let alpha_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                                    alpha_node.default_value = 0.1
                                    alpha_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_GAIN
                                    alpha_node.proxy_description = "Gain -> Actor: \(actor_description) \(buffer) \(target_node.lexeme!)"
                                    
                                    // Beta node (order)
                                    let beta_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                                    beta_node.default_value = 1.0
                                    beta_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_ORDER
                                    beta_node.proxy_description = "Order -> Actor: \(actor_description) \(buffer) \(target_node.lexeme!)"
                                    
                                    // grab for later -
                                    control_parameter_proxy_array.append(alpha_node)
                                    control_parameter_proxy_array.append(beta_node)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.TRANSCRIPTION){
            
            // Grab this node, we'll need it later
            if let _transcription_root_node = node as? SyntaxTreeComposite {
                
                self.transcription_root_node = _transcription_root_node
                
                // what are the targets for this transcription process?
                if let _target_relationship_node = _transcription_root_node.getChildAtIndex(1) as? SyntaxTreeComposite {
                    self.target_node_array = _target_relationship_node.children_array
                }
            }
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        return control_parameter_proxy_array
    }
}

final class BiologicalTypeDictionarySyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
    init() {
    }
    
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        // ok, if we are visiting a type node, grab the types
        if (node.tokenType == TokenType.TYPE){
            
            if let composite = (node as? SyntaxTreeComposite) {
                
                // ok, we need to get the prefix *and* the type -
                let prefix_node = composite.getChildAtIndex(0)
                let type_node = composite.getChildAtIndex(1)
                
                // setup the key -
                type_dictionary[prefix_node!.lexeme!] = type_node
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        return type_dictionary
    }
}

final class ProteinTranslationKineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var translation_kinetics_array = [VLEMProxyNode]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }

    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
            
            if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.PROTEIN){
                
                // Create a new mRNA node - get the prefix -
                
                
                
                // ok, we have a protein node! We have a slang expression. Need to make a gene type, and then build a proxy around it.
                let mrna_node = SyntaxTreeComponent(type: TokenType.MESSENGER_RNA)
                
                // ok, we have a DNA node! I need to split off the prefix from this node -
                if let _prefix = VLEMAbstractSyntaxTreeVisitorLibrary.getBiologicalSymbolPrefix(type_dictionary, tokenType:TokenType.MESSENGER_RNA), let _node_symbol = node.lexeme {
                    
                    // mRNA node text -
                    mrna_node.lexeme = _prefix+_node_symbol
                }
                else {
                    mrna_node.lexeme = "white_fluffy_cloud_node"
                }
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMProteinTranslationKineticsFunctionProxy(node: mrna_node)
                
                // Add to the proxy *if* we have not seen this before ...
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(translation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    translation_kinetics_array.append(proxy_node)
                }
            }
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // Don't walk down the control part of the tree ...
        if (node.tokenType == TokenType.INDUCE || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.INDUCES){
            return false
        }
        
        return true
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // how many proteins do we have?
        let number_of_proteins = translation_kinetics_array.count
        var local_counter = 1
        for proxy_object in translation_kinetics_array {
            
            if let _proxy_node = proxy_object as? VLEMProteinTranslationKineticsFunctionProxy {
                
                _proxy_node.protein_index = local_counter
                _proxy_node.parameter_array_base_index = number_of_proteins
                
                // update counter -
                local_counter++
            }
        }
        
        return translation_kinetics_array
    }
}

final class ProteinDegradationKineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var degradation_kinetics_array = [VLEMProxyNode]()
    private var protein_counter = 1
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
         
            if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.PROTEIN){
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMProteinDegradationKineticsFunctionProxy(node: node)
                proxy_node.protein_index = protein_counter
                
                // Add to the proxy *if* we have not seen this before ...
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(degradation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    degradation_kinetics_array.append(proxy_node)
                }
            }
            else if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.DNA) {
                
                // Build mRNA node -
                let protein_node = SyntaxTreeComponent(type: TokenType.PROTEIN)
                
                // ok, we have a DNA node! I need to split off the prefix from this node -
                if let _node_symbol = VLEMAbstractSyntaxTreeVisitorLibrary.removeTypePrefixFromNodeLexeme(node, type_dictionary: type_dictionary) {
                    protein_node.lexeme = _node_symbol
                }
                else {
                    protein_node.lexeme = "white_fluffy_cloud_node"
                }
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMProteinDegradationKineticsFunctionProxy(node:protein_node)
                proxy_node.protein_index = protein_counter
                
                // Add to the proxy *if* we have not seen this before ...
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(degradation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    degradation_kinetics_array.append(proxy_node)
                }
            }
            
            // update the gene counter -
            protein_counter++
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // Don't walk down the control part of the tree ...
        if (node.tokenType == TokenType.INDUCE || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.INDUCES){
            return false
        }
        
        return true
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // how many proteins do we have?
        let number_of_proteins = degradation_kinetics_array.count
        var local_counter = 1
        for proxy_object in degradation_kinetics_array {
            
            if let _proxy_node = proxy_object as? VLEMProteinDegradationKineticsFunctionProxy {
                
                _proxy_node.protein_index = local_counter
                _proxy_node.parameter_array_base_index = number_of_proteins
                
                // update counter -
                local_counter++
            }
        }
        
        return degradation_kinetics_array
    }
}

final class MessengerRNADegradationineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var degradation_kinetics_array = [VLEMProxyNode]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION)
        {
            // ok, we have a target node. Now ... we need to determine if this is a protein node -or- we have a DNA node
            // either one of these is correct (listing the protein is slang, but still ok)
            if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.PROTEIN){
                
                // ok, we have a protein node! We have a slang expression. Need to make a gene type, and then build a proxy around it.
                let mrna_node = SyntaxTreeComponent(type: TokenType.MESSENGER_RNA)
                
                // ok, we have a protein, need to create a gene with prefix -
                var mrna_prefix = ""
                for (key,value) in type_dictionary {
                    
                    if value.tokenType == TokenType.MESSENGER_RNA {
                        mrna_prefix = key
                        break
                    }
                }
                
                // Set the lexeme -
                mrna_node.lexeme = mrna_prefix+node.lexeme!
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMMessengerRNADegradationKineticsFunctionProxy(node: mrna_node)
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(degradation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    degradation_kinetics_array.append(proxy_node)
                }
            }
            else if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.DNA){
                
                // Build mRNA node -
                let mrna_node = SyntaxTreeComponent(type: TokenType.MESSENGER_RNA)
                
                // ok, we have a DNA node! I need to split off the prefix from this node -
                if let _node_symbol = VLEMAbstractSyntaxTreeVisitorLibrary.removeTypePrefixFromNodeLexeme(node, type_dictionary: type_dictionary) {
                    
                    // ok, we have a protein, need to create a gene with prefix -
                    var mrna_prefix = ""
                    for (key,value) in type_dictionary {
                        
                        if value.tokenType == TokenType.MESSENGER_RNA {
                            mrna_prefix = key
                            break
                        }
                    }
                    
                    // build new symbol -
                    let new_symbol = mrna_prefix+_node_symbol
                    mrna_node.lexeme = new_symbol
                }
                else {
                    mrna_node.lexeme = "white_fluffy_cloud_node"
                }
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMMessengerRNADegradationKineticsFunctionProxy(node: mrna_node)
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(degradation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    degradation_kinetics_array.append(proxy_node)
                }
            }
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // Don't walk down the control part of the tree ...
        if (node.tokenType == TokenType.INDUCE || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.INDUCES){
            return false
        }
        
        return true
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        var counter = 1
        for proxy in degradation_kinetics_array {
            
            if let _proxy = proxy as? VLEMMessengerRNADegradationKineticsFunctionProxy {
                _proxy.mRNA_index = counter
            }
            
            counter++
        }
        
        return degradation_kinetics_array
    }

}

final class BasalGeneExpressionKineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
    }
    
    
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        // Grab the target node ...
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
            
            if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsSyntaxNode(state_node_array, node: node) == false){
                state_node_array.append(node)
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // Don't walk down the control part of the tree ...
        if (node.tokenType == TokenType.INDUCE || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.INDUCES){
            return false
        }
        
        return true
    }

    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // set the counter -
        var proxy_node_array = [VLEMProxyNode]()
        var counter = 1
        for node in state_node_array {
            
            // build basal term -
            let proxy = VLEMBasalGeneExpressionKineticsFunctionProxy(node: node)
            proxy.gene_index = (counter++)
            
            // add -
            proxy_node_array.append(proxy)
        }
        
        return proxy_node_array
    }
}

final class GeneExpressionKineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var gene_expression_kinetics_array = [VLEMProxyNode]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION)
        {
            // ok, we have a target node. Now ... we need to determine if this is a protein node -or- we have a DNA node
            // either one of these is correct (listing the protein is slang, but still ok)
            if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.PROTEIN){
                
                // ok, we have a protein node! We have a slang expression. Need to make a gene type, and then build a proxy around it.
                let gene_node = SyntaxTreeComponent(type: TokenType.DNA)
                
                // ok, we have a protein, need to create a gene with prefix -
                var gene_prefix = ""
                for (key,value) in type_dictionary {
                    
                    if value.tokenType == TokenType.DNA {
                        gene_prefix = key
                        break
                    }
                }
                
                // Set the lexeme -
                gene_node.lexeme = gene_prefix+node.lexeme!
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMGeneExpressionKineticsFunctionProxy(node: gene_node)
                
                // Cache this node, if we do *not* have it -
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(gene_expression_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    gene_expression_kinetics_array.append(proxy_node)
                }
            }
            else if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.DNA){
                
                // put the gene node in the kinetics proxy object -
                let proxy_node = VLEMGeneExpressionKineticsFunctionProxy(node: node)
                
                // Cache this node, if we do *not* have it -
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(gene_expression_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    gene_expression_kinetics_array.append(proxy_node)
                }
            }
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        var counter = 1
        for proxy in gene_expression_kinetics_array {
            
            if let _proxy = proxy as? VLEMGeneExpressionKineticsFunctionProxy {
                _proxy.gene_index = counter
            }
            
            counter++
        }
        
        return gene_expression_kinetics_array
    }

}

final class GeneExpressionControlFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var transfer_function_array = [VLEMGeneExpressionControlTransferFunctionProxy]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }

    init() {
        
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    }

    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        return transfer_function_array
    }
}

final class GeneExpressionRateParameterSyntaxTreeVistor:SyntaxTreeVisitor {

    // Declarations -
    private var rate_node_array:[VLEMGeneExpressionRateProcessProxy] = [VLEMGeneExpressionRateProcessProxy]()
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
    private var target_node_array = [SyntaxTreeComponent]() {
        willSet(newValue) {
            
        }
    }
    
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
        
        // ok, if we are visiting a type node, grab it for later -
        if (node.tokenType == TokenType.TYPE){
            // ok, I have a type node ...
            
            if let composite = (node as? SyntaxTreeComposite) {
                
                // ok, we need to get the prefix *and* the type -
                let prefix_node = composite.getChildAtIndex(0)
                let type_node = composite.getChildAtIndex(1)
                
                // setup the key -
                type_dictionary[prefix_node!.lexeme!] = type_node
            }
        }
        
        // let's grab the targets -
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
            
            if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsSyntaxNode(target_node_array, node: node) == false){
                target_node_array.append(node)
            }
        }
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // ok, so we should have everything here now. 
        // First, we need to get a count of the number of targets that we have
        var proxy_node_array = [VLEMSpeciesProxy]()
        for node in target_node_array {
            
            // what kind of node is this?
            if let node_type = VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) where (node_type == TokenType.PROTEIN) {
                
                // ok, we have a protein node, let's build a proxy -
                let protein_proxy = VLEMSpeciesProxy(node: node)
                protein_proxy.token_type = TokenType.PROTEIN
                
                // ok, we have a protein -
                var mrna_prefix = ""
                for (key,value) in type_dictionary {
                    
                    if value.tokenType == TokenType.MESSENGER_RNA {
                        mrna_prefix = key
                    }
                }
                
                // We have a protein, we need to build a mRNA_* species
                let mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                mrna_node.lexeme = mrna_prefix+node.lexeme!
                
                // build a proxy for it -
                let mrna_node_proxy = VLEMSpeciesProxy(node: mrna_node)
                mrna_node_proxy.token_type = TokenType.MESSENGER_RNA
                
                // ok, add these nodes to my array (if they are not already there)
                proxy_node_array.append(protein_proxy)
                proxy_node_array.append(mrna_node_proxy)
            }
        }
        
        
        // let's sort this by type -
        let type_array = [TokenType.DNA,TokenType.MESSENGER_RNA,TokenType.PROTEIN,TokenType.METABOLITE]
        var sorted_target_array = [VLEMSpeciesProxy]()
        for token_type in type_array {
            
            for component_proxy in proxy_node_array {
                
                if (component_proxy.token_type == token_type){
                    sorted_target_array.append(component_proxy)
                }
            }
        }

        // Lastly, for each proxy in my sorted target array we'll create a set of reactions
        for species_proxy in sorted_target_array {
            
            
            if (species_proxy.token_type == TokenType.MESSENGER_RNA){
                
                // For this mRNA we need to create a rate proxy
                let synthesis_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                synthesis_rate_proxy.rate_description = "Transcription constant \(species_proxy.syntax_tree_node!.lexeme!)"
                synthesis_rate_proxy.default_value = 1.0
                
                let basal_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                basal_rate_proxy.rate_description = "Basal expression constant \(species_proxy.syntax_tree_node!.lexeme!)"
                basal_rate_proxy.default_value = 0.001
                
                let degradation_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                degradation_rate_proxy.rate_description = "Degradation constant \(species_proxy.syntax_tree_node!.lexeme!)"
                degradation_rate_proxy.default_value = 0.1
                
                // package -
                rate_node_array.append(synthesis_rate_proxy)
                rate_node_array.append(basal_rate_proxy)
                rate_node_array.append(degradation_rate_proxy)
            }
            else {
                
                // For this mRNA we need to create a rate proxy
                let synthesis_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                synthesis_rate_proxy.rate_description = "Translation constant \(species_proxy.syntax_tree_node!.lexeme!)"
                synthesis_rate_proxy.default_value = 10.0
                
                let degradation_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                degradation_rate_proxy.rate_description = "Degradation constant \(species_proxy.syntax_tree_node!.lexeme!)"
                degradation_rate_proxy.default_value = 0.01
                
                // package -
                rate_node_array.append(synthesis_rate_proxy)
                rate_node_array.append(degradation_rate_proxy)
            }
        }
        
        return rate_node_array
    }
}

final class BiologicalTargetSymbolSyntaxTreeVisitor: SyntaxTreeVisitor {
    
    // declarations -
    private var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        // Grab the target node ...
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
            state_node_array.append(node)
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        // Don't walk down the control part of the tree ...
        if (node.tokenType == TokenType.INDUCE || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.INDUCES){
            return false
        }
        
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // Build list of species -
        var unsorted_proxy_array = [VLEMProxyNode]()
        for component_object in state_node_array {
            
            // what type of node is this?
            if let node_type = VLEMAbstractSyntaxTreeVisitorLibrary.classifyTypeOfNode(component_object, type_dictionary: type_dictionary) where (node_type != TokenType.NULL){
                
                if (node_type == TokenType.PROTEIN){
                    
                    // ok, create the proxy with a guess of the type of node -
                    let my_protein_proxy_object = VLEMSpeciesProxy(node: component_object)
                    my_protein_proxy_object.token_type = node_type
                    
                    // store -
                    unsorted_proxy_array.append(my_protein_proxy_object)
                    
                    // Create mRNA node and proxy -
                    // ok, we have a protein node! We have a slang expression. Need to make a gene type, and then build a proxy around it.
                    let mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    
                    // ok, we have a DNA node! I need to split off the prefix from this node -
                    if let _prefix = VLEMAbstractSyntaxTreeVisitorLibrary.getBiologicalSymbolPrefix(type_dictionary, tokenType:TokenType.MESSENGER_RNA), let _node_symbol = component_object.lexeme {
                        
                        // mRNA node text -
                        mrna_node.lexeme = _prefix+_node_symbol
                        
                        // Create the porxy -
                        let my_mrna_proxy_object = VLEMSpeciesProxy(node: mrna_node)
                        my_mrna_proxy_object.token_type = TokenType.MESSENGER_RNA
                        
                        // Add proxy to array -
                        unsorted_proxy_array.append(my_mrna_proxy_object)
                    }
                }
                else if (node_type == TokenType.DNA){
                    
                    // ok, we have a gene, need to make an mRNA node -
                    // Create mRNA node and proxy -
                    let mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    
                    // ok, we have a gene node! I need to split off the prefix from this node -
                    if let _prefix = VLEMAbstractSyntaxTreeVisitorLibrary.getBiologicalSymbolPrefix(type_dictionary, tokenType:TokenType.MESSENGER_RNA), let _node_symbol = component_object.lexeme {
                        
                        // mRNA node text -
                        mrna_node.lexeme = _prefix+_node_symbol
                        
                        // Create the porxy -
                        let my_mrna_proxy_object = VLEMSpeciesProxy(node: mrna_node)
                        my_mrna_proxy_object.token_type = TokenType.MESSENGER_RNA
                        
                        // Add proxy to array -
                        unsorted_proxy_array.append(my_mrna_proxy_object)
                    }
                }
            }
        }

        // Sort the proxy array -
        let type_array = [TokenType.DNA,TokenType.MESSENGER_RNA,TokenType.PROTEIN,TokenType.METABOLITE]
        var sorted_proxy_array = [VLEMProxyNode]()
        for token_type in type_array {
            
            for component_proxy in unsorted_proxy_array {
                
                if let _component_proxy = component_proxy as? VLEMSpeciesProxy {
                    
                    if (_component_proxy.token_type == token_type){
                        sorted_proxy_array.append(_component_proxy)
                    }
                }
            }
        }

        if (sorted_proxy_array.count>0){
            return sorted_proxy_array
        }
        
        return nil
    }
}

final class BiologicalSymbolSyntaxTreeVisitor: SyntaxTreeVisitor {
    
    // declarations -
    private var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    internal var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    init() {
        
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.tokenType != TokenType.TYPE){
            
            if (arrayContains(state_node_array, node: node) == false){
                state_node_array.append(node)
            }
        }
        else if (node.tokenType == TokenType.TYPE){
            // ok, I have a type node ...
            
            if let composite = (node as? SyntaxTreeComposite) {
                
                // ok, we need to get the prefix *and* the type -
                let prefix_node = composite.getChildAtIndex(0)
                let type_node = composite.getChildAtIndex(1)
                
                // setup the key -
                type_dictionary[prefix_node!.lexeme!] = type_node
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    
        // ok, we just visted this node. If it was a protein node, then we need to create an
        // mRNA *and* DNA node associated with it
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.tokenType != TokenType.TYPE){
        
            if let node_type = VLEMAbstractSyntaxTreeVisitorLibrary.classifyTypeOfNode(node,type_dictionary: type_dictionary) where (node_type == TokenType.PROTEIN){
                
                var gene_prefix = ""
                var mrna_prefix = ""
                for (key,value) in type_dictionary {
                    
                    if value.tokenType == TokenType.MESSENGER_RNA {
                        mrna_prefix = key
                    }
                    else if (value.tokenType == TokenType.DNA) {
                        gene_prefix = key
                    }
                }
                
                // We have a protein, we need to build a GENE_* and mRNA_* species
                let gene_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                gene_node.lexeme = gene_prefix+node.lexeme!
                
                let mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                mrna_node.lexeme = mrna_prefix+node.lexeme!
                
                // ok, add these nodes to my array (if they are not already there)
                if (arrayContains(state_node_array, node: gene_node) == false){
                    state_node_array.append(gene_node)
                    state_node_array.append(mrna_node)
                }
            }
        }
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // Build list of species -
        var proxy_array = [VLEMSpeciesProxy]()
        for component_object in state_node_array {
            
            if let node_type = VLEMAbstractSyntaxTreeVisitorLibrary.classifyTypeOfNode(component_object,type_dictionary:type_dictionary) where (node_type != TokenType.NULL){
                
                // ok, create the proxy with a guess of the type of node -
                let my_proxy_object = VLEMSpeciesProxy(node: component_object)
                my_proxy_object.token_type = node_type
                
                // specify default values different types -
                if (node_type == TokenType.DNA)
                {
                    my_proxy_object.default_value = 1.0
                }
                else {
                    my_proxy_object.default_value = 0.0
                }
                
                // store -
                proxy_array.append(my_proxy_object)
            }
        }
        
        // ok, so let's sort these species by their biological types, DNA,MRNA, PROTEIN and METABOLITE
        let type_array = [TokenType.DNA,TokenType.MESSENGER_RNA,TokenType.PROTEIN,TokenType.METABOLITE]
        var sorted_proxy_array = [VLEMProxyNode]()
        for token_type in type_array {
            
            for component_proxy in proxy_array {
            
                if (component_proxy.token_type == token_type){
                    sorted_proxy_array.append(component_proxy)
                }
            }
        }
        
        if (sorted_proxy_array.count>0){
            return sorted_proxy_array
        }
        
        return nil
    }
    
    
    // MARK: - Private helper functions
    private func arrayContains(array:[SyntaxTreeComponent],node:SyntaxTreeComponent) -> Bool {
        
        for item in array {
            
            if (item.lexeme == node.lexeme){
                return true
            }
        }
        
        return false
    }
    
    private func matchLogic(characterStack:[Character],matchArray:[Character]) -> Bool {
        
        // go thru the chars, until we do *not* match
        let number_of_chars = matchArray.count
        for var char_index = 0;char_index<number_of_chars;char_index++ {
            
            if (characterStack[char_index] != matchArray[char_index]){
                
                return false
            }
        }
        
        // default - true
        return true
    }

}
