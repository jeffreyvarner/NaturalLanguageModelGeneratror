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
    
    
    // ok, we have a few comparison methods to check if a symbol is a substrate, or a product -
    func isModelSymbolASubstrate(symbol:String) -> Bool {
        
        // declarations --
        var return_flag = false
        
        if let local_symbol_list = reactant_symbol_list {
        
            for test_symbol in local_symbol_list {
                
                if (test_symbol == symbol){
                    return_flag = true
                    break
                }
                
            }
        }
        
        
        // return -
        return return_flag
    }
    
    func isModelSymbolAProduct(symbol:String) -> Bool {
        
        // declarations --
        var return_flag = false
        
        if let local_symbol_list = product_symbol_list {
            
            for test_symbol in local_symbol_list {
                
                if (test_symbol == symbol){
                    return_flag = true
                    break
                }
                
            }
        }
        
        // return -
        return return_flag
    }
}
