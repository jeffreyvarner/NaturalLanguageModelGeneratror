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



class TestSyntaxTreeVisitor: SyntaxTreeVisitor {
    
    // declarations -
    var state_node_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()
    
    func visit(node:SyntaxTreeComponent) -> Void {
        
        if (node.tokenType == TokenType.BIOLOGICAL_SYMBOL){
            
            state_node_array.append(node)
        }
        
        println("visit called on \(node.lexeme!)")
    }
    
    func shouldVisit(node:SyntaxTreeComponent) -> Bool {
        
        if (node.tokenType == TokenType.OR && node.parent_pointer?.tokenType == TokenType.TRANSCRIPTION){
            return false
        }
        
        return true
    }
    
    func willVisit(node:SyntaxTreeComponent) -> Void {
        println("willVisit called on \(node.lexeme!)")
    }
    
    func didVisit(node:SyntaxTreeComponent) -> Void {
        println("didVisit called on \(node.lexeme!)")
    }
    
    func printNodeList() -> Void {
        for node in state_node_array {
            
            println("Node: \(node.lexeme!)")
        }
    }
}

