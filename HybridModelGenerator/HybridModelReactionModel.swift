//
//  HybridModelReactionModel.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/30/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class HybridModelReactionModel: NSObject {
    
    // Declarations -
    var reaction_identifier:String
    var reactant_symbol_list:[String]?
    var product_symbol_list:[String]?
    var catalyst_symbol:String?
    
    override init(){
        
        // initialize identifier -
        self.reaction_identifier = NSUUID().UUIDString
    }    
}
