//
//  SyntaxTreeComponent.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa


enum VLEMSpeciesProxyType {
    
    case PROXY_TYPE_PROTEIN
    case PROXY_TYPE_MESSENGER_RNA
    case PROXY_TYPE_REGULATORY_RNA
    case PROXY_TYPE_GENE_DNA
    case PROXY_TYPE_NULL
}

class SyntaxTreeComponent: NSObject {
    
    // declarations -
    var tokenType:TokenType
    var lexeme:String?
    
    weak var parent_pointer:SyntaxTreeComponent?
    
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
