//
//  VLEMAbstractSyntaxTreeLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/4/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol ASTBuilder {
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent
}

class VLEMAbstractSyntaxTreeLibrary: NSObject {

}

// MARK: - System transfer abstract syntax tree -
class SystemTransferSyntaxTreeBuilderLogic:ASTBuilder {
    
    init (){
        
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildSystemTransferSyntaxTreeWithScanner(scanner)
    }
    
    private func buildSystemTransferSyntaxTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
        // Declarations -
        var system_transfer_subtree = SyntaxTreeComposite(type:TokenType.SYSTEM)
        system_transfer_subtree.lexeme = "system"
        
        var direction_node:SyntaxTreeComposite?
        var biological_species_array = [SyntaxTreeComponent]()
        
        // ok, iterate through the tokens and construct tree -
        for _token in scanner {
            
            // Grab the direction token type -
            if (_token.token_type == TokenType.FROM || _token.token_type == TokenType.TO){
                direction_node = SyntaxTreeComposite(type: _token.token_type!)
            }
            
            // Grab the species -
            if (_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // Build species -
                var species_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                species_node.lexeme = _token.lexeme
                
                // grab the species -
                biological_species_array.append(species_node)
            }
        }
        
        // ok -
        for _species in biological_species_array {
            
            if let _direction_node = direction_node {
                
                _direction_node.addNodeToTree(_species)
            }
        }
        
        // add direction node to system -
        if let _direction_node = direction_node {
            system_transfer_subtree.addNodeToTree(_direction_node)
        }
        
        // build -
        return system_transfer_subtree
    }    
}


// MARK: - Type assignment abstract syntax tree
class TypeAssignmentSyntaxTreeBuilderLogic:ASTBuilder {
    
    init (){
        
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildTypeAssignmentPrefixSubtreeTreeWithScanner(scanner)
    }
    
    private func buildTypeAssignmentPrefixSubtreeTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
    
        // Declarations -
        var type_subtree = SyntaxTreeComposite(type: TokenType.TYPE)
        type_subtree.lexeme = "type"
        
        // ok, we just need to grab the first and last token (if we get here, then we have a correct syntax)
        return recursiveBuildTypeAssignmentSubtree(scanner, node: type_subtree) as! SyntaxTreeComposite
    }
    
    func recursiveBuildTypeAssignmentSubtree(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let next_token = scanner.getNextToken() {
            
            if (next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                if let local_node = node where ((local_node as? SyntaxTreeComposite) != nil) {
                    var composite = local_node as! SyntaxTreeComposite
                    
                    // Create leaf -
                    var leaf_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    leaf_node.lexeme = next_token.lexeme
                    
                    // add the leaf to composite -
                    composite.addNodeToTree(leaf_node)
                    
                    // keep going down the statement -
                    return recursiveBuildTypeAssignmentSubtree(scanner, node: composite)
                }
            }
            else if (next_token.token_type == TokenType.PROTEIN ||
                next_token.token_type == TokenType.MESSENGER_RNA ||
                next_token.token_type == TokenType.METABOLITE ||
                next_token.token_type == TokenType.REGULATORY_RNA ||
                next_token.token_type == TokenType.DNA) {
                    
                // ok, we are at the bottom of the stack -
                if let local_node = node where ((local_node as? SyntaxTreeComposite) != nil) {
                    var composite = local_node as! SyntaxTreeComposite
                    
                    // Create a leaf node with the type -
                    var leaf_node = SyntaxTreeComponent(type:next_token.token_type!)
                    leaf_node.lexeme = next_token.lexeme
                    
                    // Add -
                    composite.addNodeToTree(leaf_node)
                    
                    // return the composite -
                    return composite
                }
            }
            else {
                
                // we have a different type of token, skip and keep going down the statement -
                return recursiveBuildTypeAssignmentSubtree(scanner, node:node)
            }
        }
        
        // return -
        return nil
    }
}

// MARK: - Transcription abstract syntax tree
class TranscriptionSyntaxTreeBuilderLogic:ASTBuilder {
    
    
    init (){
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildTranscriptionStatementControlTreeWithScanner(scanner)
    }
    
    
    // MARK: - Tree node creation methods
    private func buildTranscriptionStatementControlTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
        // Declarations -
        var transcription_node = SyntaxTreeComposite(type: TokenType.TRANSCRIPTION)
        transcription_node.lexeme = "transcription"
        
        // What type of control do we have?
        var control_node = buildControlStatementNodeWithScanner(scanner)
        
        if let source_subtree = buildComplexStatementNodeWithScanner(scanner),
            target_subtree = buildComplexStatementNodeWithScanner(scanner) {
                
                // add source tree to control node -
                control_node.addNodeToTree(source_subtree)
                
                // add control node to transcription node -
                transcription_node.addNodeToTree(control_node)
                
                // Add target subtree to transcription node -
                transcription_node.addNodeToTree(target_subtree)
        }
        
        // return -
        return transcription_node
    }
    
    
    private func buildComplexStatementNodeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComponent? {
        
        
        // What symbols are associated with the control node?
        if let first_token = scanner.getNextToken() {
            
            if (first_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // Ok, we have a simple statement - create an OR, add the species to it, and then add OR to control node
                var or_node = SyntaxTreeComposite(type: TokenType.OR)
                or_node.lexeme = "or"
                
                // Create species component node -
                var species_component = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                species_component.lexeme = first_token.lexeme
                
                // Add species to OR node -
                or_node.addNodeToTree(species_component)
                
                // return -
                return or_node
            }
            else if (first_token.token_type == TokenType.LPAREN){
                
                // ok, so we have a more complicated situation.
                // We have a (species AND species) -or- (species OR species) clause
                if var relationship_subtree = buildRelationshipSubtreeNodeWithScanner(scanner,node: nil) {
                    
                    return relationship_subtree
                }
            }
        }
        
        // return the control node -
        return nil
    }
    
    private func buildRelationshipSubtreeNodeWithScanner(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let next_token = scanner.getNextToken() {
            
            if (next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // ok, create symbol node -
                var symbol_leaf = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                symbol_leaf.lexeme = next_token.lexeme
                
                if let local_parent_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.AND || node?.tokenType == TokenType.OR) {
                    
                    // add my leaf to the node that was passed in -
                    local_parent_node.addNodeToTree(symbol_leaf)
                    
                    // ok, let's keep going, call me with the leaf that I just created -
                    return buildRelationshipSubtreeNodeWithScanner(scanner, node:local_parent_node)
                }
                
                // ok, let's keep going, call me with the leaf that I just created -
                return buildRelationshipSubtreeNodeWithScanner(scanner, node: symbol_leaf)
            }
            else if (next_token.token_type == TokenType.AND ||
                next_token.token_type == TokenType.OR){
                    
                    // ok, we have a relationship, do we have a node that was passed in?
                    if let local_node = node where (node?.tokenType == TokenType.BIOLOGICAL_SYMBOL) {
                        
                        var relationship_node = SyntaxTreeComposite(type: next_token.token_type!)
                        relationship_node.lexeme = next_token.lexeme
                        
                        // ok, grab the node that was passed in -
                        relationship_node.addNodeToTree(local_node)
                        
                        // call me again -
                        return buildRelationshipSubtreeNodeWithScanner(scanner, node: relationship_node)
                    }
                    else if let local_node = node where (node?.tokenType == TokenType.AND || node?.tokenType == TokenType.OR) {
                        
                        // ok, we have another AND/OR, but we've already built the relationship node.
                        // keep going down the stack -
                        return buildRelationshipSubtreeNodeWithScanner(scanner, node: local_node)
                    }
        
            }
            else if (next_token.token_type == TokenType.RPAREN)
            {
                return node
            }
        }
        
        // no more tokens?
        return nil
    }
    
    private func buildControlStatementNodeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
        // what type of control node do we have?
        
        // Get the "control" type (induce, induces etc)
        let control_token_type = scanner.getControlTokenType()
        
        // remove the control type node -
        scanner.removeTokenOfType(control_token_type)
        
        // Create the control node -
        var control_node = SyntaxTreeComposite(type: control_token_type)
        control_node.lexeme = "control_node"
        
        // return my control node -
        return control_node
    }
}
