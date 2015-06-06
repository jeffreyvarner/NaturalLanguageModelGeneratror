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

class BiologicalSymbolSyntaxTreeVisitor: SyntaxTreeVisitor {
    
    // declarations -
    var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL){
            
            if (arrayContains(state_node_array, node: node) == false){
                state_node_array.append(node)
            }
        }
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
    }
    
    func didVisit(node:SyntaxTreeComponent) -> Void {
    
        // ok, we have a list of species, for protien species I need to add
        // a gene and mRNA for each unique protein -
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL){
        
            // Declarations -
            var protein_match_array:[Character] = ["p","r","o","t","e","i","n","_"]
            var tmp_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
            
            // iterate through the component array -
            for component_object in state_node_array {
                
                if let component_lexeme = component_object.lexeme {
                    
                    // Build char array -
                    var lexeme_char_array = [Character]()
                    
                    // check, is this a protein?
                    for local_char in component_lexeme {
                        lexeme_char_array.append(local_char)
                    }
                    
                    if (matchLogic(lexeme_char_array, matchArray: protein_match_array) == true){
                        
                        // We have a protein, we need to build a GENE_* and mRNA_* species
                        var gene_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                        gene_node.lexeme = "gene_"+component_lexeme
                        
                        var mrna_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                        mrna_node.lexeme = "mRNA_"+component_lexeme
                        
                        if (arrayContains(tmp_array, node: mrna_node) == false){
                            tmp_array.append(gene_node)
                            tmp_array.append(mrna_node)
                        }
                    }
                }
            }
            
            // add these to the state array -
            for component_object in tmp_array {
                if (arrayContains(state_node_array, node: component_object) == false){
                    state_node_array.append(component_object)
                }
            }
        }
    }
    
    func getSyntaxTreeVisitorData() -> Any? {
        
        // Build list of species -
        var proxy_array = [VLEMSpeciesProxy]()
        for component_object in state_node_array {
            
            // create a proxy -
            var my_proxy_object = VLEMSpeciesProxy(node: component_object)
            my_proxy_object.default_value = 1.0
            
            // store -
            proxy_array.append(my_proxy_object)
        }
        
        if (proxy_array.count>0){
            return proxy_array
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
