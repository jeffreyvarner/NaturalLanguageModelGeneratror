//
//  VLEMAbstractSyntaxTreeVistorLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class VLEMAbstractSyntaxTreeVisitorLibrary: NSObject {

}

class GeneExpressionRateSyntaxTreeVistor:SyntaxTreeVisitor {

    
    
    func visit(node:SyntaxTreeComponent) -> Void {
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node: SyntaxTreeComponent) -> Void {
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        return nil
    }
}

class BiologicalSymbolSyntaxTreeVisitor: SyntaxTreeVisitor {
    
    // declarations -
    var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    var type_dictionary = Dictionary<String,SyntaxTreeComponent>()
    
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
                my_proxy_object.species_token_type = node_type
                
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
            
                if (component_proxy.species_token_type == token_type){
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
