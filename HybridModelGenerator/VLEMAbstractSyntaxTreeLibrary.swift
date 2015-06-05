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

class TranscriptionSyntaxTreeBuilderLogic:ASTBuilder {
    
    
    init (){
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildTranscriptionStatementControlTreeWithScanner(scanner)
    }
    
    
    // MARK: - Tree node creation methods
    func buildTranscriptionStatementControlTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
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
    
    
    func buildComplexStatementNodeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComponent? {
        
        
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
    
    func buildRelationshipSubtreeNodeWithScanner(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let next_token = scanner.getNextToken() {
            
            if (next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // ok, create symbol node -
                var symbol_leaf = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                symbol_leaf.lexeme = next_token.lexeme
                
                if let local_parent_node = node as? SyntaxTreeComposite {
                    
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
                    if let local_node = node {
                        
                        var relationship_node = SyntaxTreeComposite(type: next_token.token_type!)
                        relationship_node.lexeme = next_token.lexeme
                        
                        // ok, grab the node that was passed in -
                        relationship_node.addNodeToTree(local_node)
                        
                        // call me again -
                        return buildRelationshipSubtreeNodeWithScanner(scanner, node: relationship_node)
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
    
    func buildControlStatementNodeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
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
