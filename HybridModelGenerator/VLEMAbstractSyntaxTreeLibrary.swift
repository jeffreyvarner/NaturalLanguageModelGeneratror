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

// MARK: - Metabolic control syntax tree builder -
class MetabolicControlSyntaxTreeBuilderLogic:ASTBuilder {

    init (){
        
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildMetabolicControlSyntaxTreeWithScanner(scanner)
    }

    private func buildMetabolicControlSyntaxTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
    
        // Build the parenet node ..
        let parent_node = SyntaxTreeComposite(type: TokenType.ACTIVATE)
        
        // build the control tree ...
        if let _control_tree = recursiveTreeBuilder(scanner, node: nil) as? SyntaxTreeComposite {
            return _control_tree
        }
        
        // return
        return parent_node
    }
    
    private func recursiveTreeBuilder(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let _next_token = scanner.getNextToken() {
        
            if (_next_token.token_type == TokenType.BIOLOGICAL_SYMBOL && node != nil){
             
                if let _parent_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.ACTIVATES ||
                    node?.tokenType == TokenType.ACTIVATE ||
                    node?.tokenType == TokenType.INHIBITS ||
                    node?.tokenType == TokenType.INHIBIT){
                    
                    // Build the relationship container - this call consumes a token ...
                    let _relationship_container = buildRelationshipSubtreeWithScanner(scanner)
                    
                    // ok, add the current node to the container -
                    let _species_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    _species_node.lexeme = _next_token.lexeme
                    _relationship_container!.addNodeToTree(_species_node)
                        
                    // Add relationship container to parent node -
                    _parent_node.addNodeToTree(_relationship_container!)
                        
                    // set the parent pointer (we are going to need this later ..)
                    _relationship_container!.parent_pointer = _parent_node
                    
                    // go down again -
                    return recursiveTreeBuilder(scanner, node: _relationship_container)
                }
                else if let _parent_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.AND || node?.tokenType == TokenType.OR) {
                    
                    // ok, we have an and -or- or .. add species node to container and go around again ...
                    
                    // ok, add the current node to the container -
                    let _species_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    _species_node.lexeme = _next_token.lexeme
                    
                    // add species to parent -
                    _parent_node.addNodeToTree(_species_node)
                    
                    // go down again ...
                    return recursiveTreeBuilder(scanner, node: _parent_node)
                }
            }
            else if (_next_token.token_type == TokenType.AND && node != nil){
                
                // ok, we have an AND - if this is working correctly, our parent node should be an AND -
                // do nothing, go down again -
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.OR && node != nil){
                
                // ok, we have an OR - if this is working correctly, our parent node should be an OR -
                // do nothing, go down again -
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.BIOLOGICAL_SYMBOL && node == nil){
                
                // ok, we have a biological symbol with no container node - this means we have a bare symbol
                // at the start of the sentence. Create a container node (OR), add a species to it and go down 
                // again ...
                
                // create an OR -
                let _or_subtree = SyntaxTreeComposite(type: TokenType.OR)
                _or_subtree.lexeme = "or"
                
                // Create species node -
                let _species_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                _species_node.lexeme = _next_token.lexeme
                
                // Add species to or -
                _or_subtree.addNodeToTree(_species_node)
                
                // go down again -
                return recursiveTreeBuilder(scanner, node: _or_subtree)
            }
            else if (_next_token.token_type == TokenType.ACTIVATE ||
                _next_token.token_type == TokenType.ACTIVATES ||
                _next_token.token_type == TokenType.INHIBIT ||
                _next_token.token_type == TokenType.INHIBITS &&
                node != nil) {
                    
                // ok, we have an action token - create a control statement
                let _control_node = buildControlStatementNodeWithScanner(scanner,tokenType:_next_token.token_type!)
                    
                // Create the control node, add the relationship tree to the control tree
                _control_node.addNodeToTree(node!)
                    
                // ok, go down again -
                return recursiveTreeBuilder(scanner, node: _control_node)
            }
            else if (_next_token.token_type == TokenType.LPAREN){
                
                // ok, we have a (, keep going ...
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.RPAREN){
                
                // ok, we have a ), keep going ...
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.SEMICOLON && node != nil){
                
                // we hit the bottom ... node should be an AND or OR, return the parent pointer ...
                if let _parent_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.AND || node?.tokenType == TokenType.OR){
                    
                    return _parent_node.parent_pointer
                }
            }
        }
        
        
        // default is nil -
        return nil
    }
    
    private func buildRelationshipSubtreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite? {
    
        if let _next_token = scanner.getNextToken() {
        
            if (_next_token.token_type == TokenType.AND){
                
                let _and_node = SyntaxTreeComposite(type: TokenType.AND)
                _and_node.lexeme = "and"
                
                return _and_node
            }
            else {
                
                let _or_node = SyntaxTreeComposite(type: TokenType.OR)
                _or_node.lexeme = "or"
                
                return _or_node
            }
        }
        
        return nil
    }
    
    private func buildControlStatementNodeWithScanner(scanner:VLEMScanner,tokenType:TokenType) -> SyntaxTreeComposite {
        
        // what type of control node do we have?
        
        // Get the "control" type (induce, induces etc)
        let control_token_type = tokenType
        
        // remove the control type node -
        scanner.removeTokenOfType(control_token_type)
        
        // Create the control node -
        let control_node = SyntaxTreeComposite(type: control_token_type)
        control_node.lexeme = "control_node"
        
        // return my control node -
        return control_node
    }
}

// MARK: - Metabolic stoichiometry syntax tree builder -
class MetabolicStoichiometrySyntaxTreeBuilderLogic:ASTBuilder {
    
    init (){
        
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildMetabolicStoichiometrySyntaxTreeWithScanner(scanner)
    }

    private func buildMetabolicStoichiometrySyntaxTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {

        if let _metabolic_branch = recursiveTreeBuilder(scanner, node: nil) as? SyntaxTreeComposite {
            return _metabolic_branch
        }
        else {
            
            // ok, so we didn't return ... refresh the scanner and try again
            scanner.refreshScanner()
            
            // Try the alternative grammer -
            if let _alternative_metabolic_branch = recursiveTreeBuilderAlternativeMetabolicGrammer(scanner, node: nil) as? SyntaxTreeComposite {
                return _alternative_metabolic_branch;
            }
        }
        
        // return empty catalyze -
        return SyntaxTreeComposite(type: TokenType.CATALYZE)
    }
    
    private func recursiveTreeBuilderAlternativeMetabolicGrammer(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (_next_token.token_type == TokenType.LPAREN && node == nil){
                
                // create an OR subtree -
                let or_subtree = SyntaxTreeComposite(type: TokenType.OR)
                
                // recursive call
                return recursiveTreeBuilderAlternativeMetabolicGrammer(scanner, node:or_subtree)
            }
            else if (_next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // ok, we have a biological symbol *and* an OR node
                if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.OR){
                    
                    // ok, we have a symbol and an OR -
                    
                    let enzyme_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    enzyme_node.lexeme = _next_token.lexeme

                    // add the enzyme node to to the _local_node -
                    _local_node.addNodeToTree(enzyme_node)
                    
                    // go down again ...
                    return recursiveTreeBuilderAlternativeMetabolicGrammer(scanner, node: _local_node)
                }
            }
            else if (_next_token.token_type == TokenType.OR){
                
                // ok, go down again ...
                return recursiveTreeBuilderAlternativeMetabolicGrammer(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.CATALYZE || _next_token.token_type == TokenType.CATALYZES || _next_token.token_type == TokenType.CATALYZED){
                // ok, go down again ...
                return recursiveTreeBuilderAlternativeMetabolicGrammer(scanner, node: node)
            }
        }
        
        // return nil -
        return nil
    }
    
    private func recursiveTreeBuilder(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (_next_token.token_type == TokenType.LPAREN && node == nil){
             
                // ok, we have a let paren - create a AND node -
                let and_subtree = SyntaxTreeComposite(type: TokenType.AND)
                
                // recursive call, pass in the AND -
                return recursiveTreeBuilder(scanner, node: and_subtree)
            }
            else if (_next_token.token_type == TokenType.LPAREN && node != nil){
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.RPAREN){
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.OR) {
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.GENERATES_SYMBOL){
                
                
                // add node to the generates symbol -
                if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.AND || node?.tokenType == TokenType.OR){
                    
                    // we have a generates symbol -
                    let generates_subtree = SyntaxTreeComposite(type: TokenType.GENERATES_SYMBOL)
                    
                    // add local node to generates -
                    generates_subtree.addNodeToTree(_local_node)
                    
                    // keep going down ...
                    return recursiveTreeBuilder(scanner, node: generates_subtree)
                }
            }
            else if (_next_token.token_type == TokenType.REVERSIBLE_GENERATES_SYMBOL){
                
                
                // add node to the generates symbol -
                if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.AND || node?.tokenType == TokenType.OR){
                    
                    // we have a generates symbol -
                    let generates_subtree = SyntaxTreeComposite(type: TokenType.REVERSIBLE_GENERATES_SYMBOL)
                    
                    // add local node to generates -
                    generates_subtree.addNodeToTree(_local_node)
                    
                    // keep going down ...
                    return recursiveTreeBuilder(scanner, node: generates_subtree)
                }
            }
            else if (_next_token.token_type == TokenType.CATALYZE || _next_token.token_type == TokenType.CATALYZES || _next_token.token_type == TokenType.CATALYZED){
                
                // add node to the generates symbol -
                if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.GENERATES_SYMBOL || node?.tokenType == TokenType.REVERSIBLE_GENERATES_SYMBOL){
                
                    // create a catalyzed node -
                    let catalyze_subtree = SyntaxTreeComposite(type: TokenType.CATALYZE)
                    
                    // Add local node to catalyze subtree -
                    catalyze_subtree.addNodeToTree(_local_node)
                    
                    // keep going down ...
                    return recursiveTreeBuilder(scanner, node: catalyze_subtree)
                }
                
            }
            else if (_next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // ok, we have a biological symbol -
                if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.AND) {
                    
                    // ok, we have an AND node passed in, grab the symbol and add to the AND node
                    let metabolite_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    metabolite_node.lexeme = _next_token.lexeme
                    
                    // add -
                    _local_node.addNodeToTree(metabolite_node)
                    
                    // recursive call again -
                    return recursiveTreeBuilder(scanner, node: _local_node)
                }
                else if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.CATALYZE) {
                    
                    // create an OR node, add this symbol to the OR node and then keep going down -
                    
                    let protein_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    protein_node.lexeme = _next_token.lexeme
                    
                    let or_subtree = SyntaxTreeComposite(type: TokenType.OR)
                    or_subtree.addNodeToTree(protein_node)
                    or_subtree.parent_pointer = _local_node
                    
                    // add OR to _local_node 
                    _local_node.addNodeToTree(or_subtree)
                    
                    // go down again -
                    return recursiveTreeBuilder(scanner, node: or_subtree)
                }
                else if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.OR) {
                    
                    // ok, we have an AND node passed in, grab the symbol and add to the AND node
                    let metabolite_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                    metabolite_node.lexeme = _next_token.lexeme
                    
                    // add -
                    _local_node.addNodeToTree(metabolite_node)
                    
                    // recursive call again -
                    return recursiveTreeBuilder(scanner, node: _local_node)
                }
                else {
                    
                    // ok, we have a metabolite which is *not* in a list -
                    // this will be wrapped in an OR -
                    if let _local_node = node as? SyntaxTreeComposite where (node?.tokenType == TokenType.GENERATES_SYMBOL || node?.tokenType == TokenType.REVERSIBLE_GENERATES_SYMBOL){
                     
                        let metabolite_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                        metabolite_node.lexeme = _next_token.lexeme
                        
                        let or_subtree = SyntaxTreeComposite(type: TokenType.OR)
                        or_subtree.addNodeToTree(metabolite_node)
                        
                        // add or to generates -
                        _local_node.addNodeToTree(or_subtree)
                        
                        // recursive call, pass in the AND -
                        return recursiveTreeBuilder(scanner, node: _local_node)
                    }
                }
            }
            else if (_next_token.token_type == TokenType.PLUS ||
                _next_token.token_type == TokenType.IS ||
                _next_token.token_type == TokenType.ARE ||
                _next_token.token_type == TokenType.BY) {
                
                return recursiveTreeBuilder(scanner, node: node)
            }
            else if (_next_token.token_type == TokenType.SEMICOLON){
                return node?.parent_pointer
            }
        }
        
        return nil
    }
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
        let system_transfer_subtree = SyntaxTreeComposite(type:TokenType.SYSTEM)
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
                let species_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
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


// MARK: - Type assignment abstract syntax tree -
class TypeAssignmentSyntaxTreeBuilderLogic:ASTBuilder {
    
    init (){
        
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildTypeAssignmentPrefixSubtreeTreeWithScanner(scanner)
    }
    
    private func buildTypeAssignmentPrefixSubtreeTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
    
        // Declarations -
        let type_subtree = SyntaxTreeComposite(type: TokenType.TYPE)
        type_subtree.lexeme = "type"
        
        // ok, we just need to grab the first and last token (if we get here, then we have a correct syntax)
        return recursiveBuildTypeAssignmentSubtree(scanner, node: type_subtree) as! SyntaxTreeComposite
    }
    
    func recursiveBuildTypeAssignmentSubtree(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let next_token = scanner.getNextToken() {
            
            if (next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                if let local_node = node where ((local_node as? SyntaxTreeComposite) != nil) {
                    let composite = local_node as! SyntaxTreeComposite
                    
                    // Create leaf -
                    let leaf_node = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
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
                    let composite = local_node as! SyntaxTreeComposite
                    
                    // Create a leaf node with the type -
                    let leaf_node = SyntaxTreeComponent(type:next_token.token_type!)
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

// MARK: - Transcription abstract syntax tree -
class TranscriptionSyntaxTreeBuilderLogic:ASTBuilder {
    
    
    init (){
    }
    
    func build(scanner:VLEMScanner) -> SyntaxTreeComponent {
        return buildTranscriptionStatementControlTreeWithScanner(scanner)
    }
    
    
    // MARK: - Tree node creation methods
    private func buildTranscriptionStatementControlTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
        // Declarations -
        let transcription_node = SyntaxTreeComposite(type: TokenType.TRANSCRIPTION)
        transcription_node.lexeme = "transcription"
        
        // What type of control do we have?
        let control_node = buildControlStatementNodeWithScanner(scanner)
        
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
                let or_node = SyntaxTreeComposite(type: TokenType.OR)
                or_node.lexeme = "or"
                
                // Create species component node -
                let species_component = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                species_component.lexeme = first_token.lexeme
                
                // Add species to OR node -
                or_node.addNodeToTree(species_component)
                
                // return -
                return or_node
            }
            else if (first_token.token_type == TokenType.LPAREN){
                
                // ok, so we have a more complicated situation.
                // We have a (species AND species) -or- (species OR species) clause
                if let relationship_subtree = buildRelationshipSubtreeNodeWithScanner(scanner,node: nil) {
                    
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
                let symbol_leaf = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
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
                        
                        let relationship_node = SyntaxTreeComposite(type: next_token.token_type!)
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
        let control_node = SyntaxTreeComposite(type: control_token_type)
        control_node.lexeme = "control_node"
        
        // return my control node -
        return control_node
    }
}
