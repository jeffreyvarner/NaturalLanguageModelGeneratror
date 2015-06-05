//
//  SyntaxTreeComponent.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol SyntaxTreeVisitor {
    
    func visit(node:SyntaxTreeComponent) -> Void
    func shouldVisit(node:SyntaxTreeComponent) -> Bool
    func willVisit(node:SyntaxTreeComponent) -> Void
    func didVisit(node:SyntaxTreeComponent) -> Void
}

class SyntaxTreeComponent: NSObject {
    
    // declarations -
    var tokenType:TokenType
    var lexeme:String?
    
    init (type:TokenType){
        self.tokenType = type
    }
    
    // vistor method -
    func accept(visitor:SyntaxTreeVisitor) -> Void {
        
        if (visitor.shouldVisit(self)){
            
            // Ok, we are ok to visit -
            // Call willVisit to do any prep work
            visitor.willVisit(self)
            
            // Visit -
            visitor.visit(self)
            
            // Call didVisit to finish up -
            visitor.didVisit(self)
        }
    }
}
