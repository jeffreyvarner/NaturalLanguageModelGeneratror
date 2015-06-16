//
//  VLEMAbstractSyntaxTreeVistorLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

final class VLEMAbstractSyntaxTreeVisitorLibrary: NSObject {

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
            for (key,value) in type_dictionary {
                
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

final class GeneExpressionControlModelSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    private var type_dictionary:Dictionary<String,SyntaxTreeComponent>
    private var control_model_dictionary:Dictionary<String,Array<VLEMControlRelationshipProxy>> = Dictionary<String,Array<VLEMControlRelationshipProxy>>()
    private var relationshipProxyArray:[VLEMControlRelationshipProxy] = [VLEMControlRelationshipProxy]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    
        if (node.tokenType == TokenType.INDUCES || node.tokenType == TokenType.REPRESSES || node.tokenType == TokenType.REPRESS || node.tokenType == TokenType.INDUCE){
            
            // we are in the control section of the tree ...
            
            // build a relationship proxy -
            var relationship_proxy = VLEMControlRelationshipProxy(node: node)
            
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
    private var type_dictionary:Dictionary<String,SyntaxTreeComponent>
    private var control_parameter_proxy_array = [VLEMGeneExpressionControlParameterProxy]()
    private var transcription_root_node:SyntaxTreeComposite?
    private var target_node_array:[SyntaxTreeComponent]?
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
    
        // declarations -
        var buffer = "Target(s):"
        
        if (node.tokenType == TokenType.OR || node.tokenType == TokenType.AND){
            
            if let _parent_pointer = node.parent_pointer {
                
                if (_parent_pointer.tokenType == TokenType.INDUCE || _parent_pointer.tokenType == TokenType.INDUCES ||
                    _parent_pointer.tokenType == TokenType.REPRESSES || _parent_pointer.tokenType == TokenType.REPRESS){
                    
                        
                    // ok, we are on the relationship node ..
                    // Are we an AND -or- an OR?
                    if (node.tokenType == TokenType.OR){
                    
                        if let _local_target_node_array = target_node_array {
                            
                            // create target string -
                            for target_node in _local_target_node_array {
                                buffer+=" \(target_node.lexeme!) "
                            }
                        }
                        
                        // An OR means we'll have seperate transfer functions, each with two parameters ..
                        if let _or_node = node as? SyntaxTreeComposite {
                        
                            let number_of_species = _or_node.numberOfChildren()
                            for var index = 0;index<number_of_species;index++ {
                                
                                // Create a parameter node, one alpha and one beta node per child
                                let _child_node = _or_node.getChildAtIndex(index)
                                
                                // Alpha node (gain)
                                var alpha_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                                alpha_node.default_value = 0.1
                                alpha_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_GAIN
                                alpha_node.proxy_description = "Gain -> Actor: \(_child_node!.lexeme!) \(buffer)"
                                
                                // Beta node (order)
                                var beta_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                                beta_node.default_value = 1.0
                                beta_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_ORDER
                                beta_node.proxy_description = "Order -> Actor: \(_child_node!.lexeme!) \(buffer)"
                                
                                // grab for later -
                                control_parameter_proxy_array.append(alpha_node)
                                control_parameter_proxy_array.append(beta_node)
                            }
                        }
                    }
                    else if (node.tokenType == TokenType.AND){
                    
                        if let _local_target_node_array = target_node_array {
                            
                            // create target string -
                            for target_node in _local_target_node_array {
                                buffer+=" \(target_node.lexeme!) "
                            }
                        }
                        
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
                            var alpha_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                            alpha_node.default_value = 0.1
                            alpha_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_GAIN
                            alpha_node.proxy_description = "Gain -> Actor: \(actor_description) \(buffer)"
                            
                            // Beta node (order)
                            var beta_node = VLEMGeneExpressionControlParameterProxy(node: transcription_root_node!)
                            beta_node.default_value = 1.0
                            beta_node.gene_expression_parameter_type = GeneExpressionParameterType.EXPRESSION_ORDER
                            beta_node.proxy_description = "Order -> Actor: \(actor_description) \(buffer)"
                            
                            // grab for later -
                            control_parameter_proxy_array.append(alpha_node)
                            control_parameter_proxy_array.append(beta_node)
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
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
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

final class ProteinDegradationKineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {
    
    // Declarations -
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var degradation_kinetics_array = [VLEMProxyNode]()
    private var protein_counter = 1
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL && node.parent_pointer?.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
         
            if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.PROTEIN){
                
                // put the gene node in the kinetics proxy object -
                var proxy_node = VLEMProteinDegradationKineticsFunctionProxy(node: node)
                proxy_node.protein_index = protein_counter
                
                // Add to the proxy *if* we have not seen this before ...
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(degradation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    degradation_kinetics_array.append(proxy_node)
                }
            }
            else if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.DNA) {
                
                // Build mRNA node -
                var protein_node = SyntaxTreeComponent(type: TokenType.PROTEIN)
                
                // ok, we have a DNA node! I need to split off the prefix from this node -
                if let _node_symbol = VLEMAbstractSyntaxTreeVisitorLibrary.removeTypePrefixFromNodeLexeme(node, type_dictionary: type_dictionary) {
                    protein_node.lexeme = _node_symbol
                }
                else {
                    protein_node.lexeme = "white_fluffy_cloud_node"
                }
                
                // put the gene node in the kinetics proxy object -
                var proxy_node = VLEMProteinDegradationKineticsFunctionProxy(node:protein_node)
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
            
            if var _proxy_node = proxy_object as? VLEMProteinDegradationKineticsFunctionProxy {
                
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
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var degradation_kinetics_array = [VLEMProxyNode]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
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
                var mrna_node = SyntaxTreeComponent(type: TokenType.MESSENGER_RNA)
                
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
                var proxy_node = VLEMMessengerRNADegradationKineticsFunctionProxy(node: mrna_node)
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(degradation_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    degradation_kinetics_array.append(proxy_node)
                }
            }
            else if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.DNA){
                
                // Build mRNA node -
                var mrna_node = SyntaxTreeComponent(type: TokenType.MESSENGER_RNA)
                
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
                    var new_symbol = mrna_prefix+_node_symbol
                    mrna_node.lexeme = new_symbol
                }
                else {
                    mrna_node.lexeme = "white_fluffy_cloud_node"
                }
                
                // put the gene node in the kinetics proxy object -
                var proxy_node = VLEMMessengerRNADegradationKineticsFunctionProxy(node: mrna_node)
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
            
            if var _proxy = proxy as? VLEMMessengerRNADegradationKineticsFunctionProxy {
                _proxy.mRNA_index = counter
            }
            
            counter++
        }
        
        return degradation_kinetics_array
    }

}

final class GeneExpressionKineticsFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var gene_expression_kinetics_array = [VLEMProxyNode]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
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
                var gene_node = SyntaxTreeComponent(type: TokenType.DNA)
                
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
                var proxy_node = VLEMGeneExpressionKineticsFunctionProxy(node: gene_node)
                
                // Cache this node, if we do *not* have it -
                if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(gene_expression_kinetics_array, node: proxy_node) == false){
                    
                    // cache -
                    gene_expression_kinetics_array.append(proxy_node)
                }
            }
            else if (VLEMAbstractSyntaxTreeVisitorLibrary.isNodeType(node, type_dictionary: type_dictionary) == TokenType.DNA){
                
                // put the gene node in the kinetics proxy object -
                var proxy_node = VLEMGeneExpressionKineticsFunctionProxy(node: node)
                
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
            
            if var _proxy = proxy as? VLEMGeneExpressionKineticsFunctionProxy {
                _proxy.gene_index = counter
            }
            
            counter++
        }
        
        return gene_expression_kinetics_array
    }

}

final class GeneExpressionControlFunctionSyntaxTreeVisitor:SyntaxTreeVisitor {

    // Declarations -
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    private var transfer_function_array = [VLEMGeneExpressionControlTransferFunctionProxy]()
    
    // We require the type dictionary -
    init(typeDictionary:Dictionary<String,SyntaxTreeComponent>){
        self.type_dictionary = typeDictionary
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
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
    private var target_node_array = [SyntaxTreeComponent]() {
        willSet(newValue) {
            
        }
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
                var protein_proxy = VLEMSpeciesProxy(node: node)
                protein_proxy.token_type = TokenType.PROTEIN
                
                // ok, we have a protein -
                var mrna_prefix = ""
                for (key,value) in type_dictionary {
                    
                    if value.tokenType == TokenType.MESSENGER_RNA {
                        mrna_prefix = key
                    }
                }
                
                // We have a protein, we need to build a mRNA_* species
                var mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                mrna_node.lexeme = mrna_prefix+node.lexeme!
                
                // build a proxy for it -
                var mrna_node_proxy = VLEMSpeciesProxy(node: mrna_node)
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
                var synthesis_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                synthesis_rate_proxy.rate_description = "Transcription constant \(species_proxy.syntax_tree_node!.lexeme!)"
                synthesis_rate_proxy.default_value = 1.0
                
                var basal_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                basal_rate_proxy.rate_description = "Basal expression constant \(species_proxy.syntax_tree_node!.lexeme!)"
                basal_rate_proxy.default_value = 0.001
                
                var degradation_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                degradation_rate_proxy.rate_description = "Degradation constant \(species_proxy.syntax_tree_node!.lexeme!)"
                degradation_rate_proxy.default_value = 0.1
                
                // package -
                rate_node_array.append(synthesis_rate_proxy)
                rate_node_array.append(basal_rate_proxy)
                rate_node_array.append(degradation_rate_proxy)
            }
            else {
                
                // For this mRNA we need to create a rate proxy
                var synthesis_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
                synthesis_rate_proxy.rate_description = "Translation constant \(species_proxy.syntax_tree_node!.lexeme!)"
                synthesis_rate_proxy.default_value = 10.0
                
                var degradation_rate_proxy = VLEMGeneExpressionRateProcessProxy(node: species_proxy.syntax_tree_node!)
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

final class BiologicalSymbolSyntaxTreeVisitor: SyntaxTreeVisitor {
    
    // declarations -
    private var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    private var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
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
        
            if let node_type = classifyTypeOfNode(node) where (node_type == TokenType.PROTEIN){
                
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
                var gene_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                gene_node.lexeme = gene_prefix+node.lexeme!
                
                var mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
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
            
            if let node_type = classifyTypeOfNode(component_object) where (node_type != TokenType.NULL){
                
                // ok, create the proxy with a guess of the type of node -
                var my_proxy_object = VLEMSpeciesProxy(node: component_object)
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
        var sorted_proxy_array = [VLEMSpeciesProxy]()
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
    private func classifyTypeOfNode(node:SyntaxTreeComponent) -> TokenType? {
        
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
