//
//  HybridModelContext.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/22/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class HybridModelContext: NSObject {
    
    // Declarations -
    var gene_expression_control_matrix:Matrix?
    var metabolic_stoichiometric_matrix:StoichiometricMatrix?
    var gene_expression_effector_array:[String]?
    var gene_expression_output_array:[String]?
    var translation_output_array:[String]?
    var state_symbol_array:[String]
    var state_model_dictionary:Dictionary<String,HybridStateModel>?
    
    var metabolic_reaction_array:[HybridModelReactionModel]?
    var metabolic_control_effector_symbol_array:[String]?
    var metabolic_control_target_symbol_array:[String]?
    var metabolic_control_table:Matrix?
    
    // init -
    override init(){
        
        // initlized the state array -
        self.state_symbol_array = [String]()
    }
    
    
    func addStateSymbolsToModelContext(state_symbol:String) -> Void {
        
        // append state symbol *if* it is not already there -
        if (contains(self.state_symbol_array,state_symbol) == false){
        
            self.state_symbol_array.append(state_symbol)
        }
    }
    
    
}
