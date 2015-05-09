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
    var reaction_index:Int = 0
    
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
    
    func isModelSymbolTheCatalyst(symbol:String) -> Bool {
        
        // declarations --
        var return_flag = false
        
        if let local_catalyst_symbol = catalyst_symbol {
        
            if (symbol == local_catalyst_symbol){
                return_flag = true
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
    
    func generateParameterSymbolArray() -> [String] {
        
        // declarations -
        var parameter_array = [String]()
        
        if let local_enzyme_symbol = catalyst_symbol {
            
            // ok, we have a catalyst, so this is a an enzyme catalyzed reaction -
            
            // build the rate -
            let rate_constant="k_\(reaction_index)"
            
            // add rate constant to array -
            parameter_array.append(rate_constant)
            
            // do we have a reactant list?
            if let local_reactant_list = reactant_symbol_list {
                
                for local_symbol in local_reactant_list {
                    
                    var tmp = "KM_\(reaction_index)_\(local_symbol)"
                    parameter_array.append(tmp)
                }
            }
        }
        else {
            
            if (isModelSymbolASubstrate("SYSTEM") == true ||
                isModelSymbolAProduct("SYSTEM") == true) {
                
                // we could have a SYSTEM transfer
                // From system -
                if let local_reactant_list = reactant_symbol_list {
                        
                    for local_symbol in local_reactant_list {
                            
                        if (local_symbol != "SYSTEM"){
                                
                            // we are going *to* the system -
                            var tmp="k_\(reaction_index)_\(local_symbol)_system"
                            parameter_array.append(tmp)
                        }
                        else {
                            var tmp = "k_\(reaction_index)_from_system"
                            parameter_array.append(tmp)
                        }
                    }
                }
            }
            else {
             
                var tmp="k_\(reaction_index)_bind"
                parameter_array.append(tmp)
            }
        }

        
        // return -
        return parameter_array
    }
    
    
    func generateReactionString() -> String {
        
        // declarations -
        var buffer = ""
        
        
        if let local_enzyme_symbol = catalyst_symbol {
            
            // ok, we have a catalyst, so this is a an enzyme catalyzed reaction -
            
            // build the rate -
            buffer+="k_\(reaction_index)*\(local_enzyme_symbol)"
            
            // do we have a reactant list?
            if let local_reactant_list = reactant_symbol_list {
                
                for local_symbol in local_reactant_list {
                    
                    buffer+="*((\(local_symbol))/(\(local_symbol)+KM_\(reaction_index)_\(local_symbol)))"
                }
            }
            
            // add a new line;
            buffer+=";\n"
        }
        else {
            
            // we could have a SYSTEM rule, or a BIND rule (we do not have a catalyst)
            if (isModelSymbolASubstrate("SYSTEM") == true ||
                isModelSymbolAProduct("SYSTEM") == true) {
                    
                // we could have a SYSTEM transfer
                // From system -
                if let local_reactant_list = reactant_symbol_list {
                    
                    for local_symbol in local_reactant_list {
                            
                        if (local_symbol != "SYSTEM"){
                                
                            // we are going *to* the system -
                            buffer+="k_\(reaction_index)_\(local_symbol)_system*(\(local_symbol));\n"
                        }
                        else {
                            buffer+="k_\(reaction_index)_from_system;\n"
                        }
                    }
                }
            }
            else {
             
                // ok, we do *not* have a SYSTEM or an enzyme. We must be a BIND step -
                buffer+="k_\(reaction_index)"
                if let local_reactant_list = reactant_symbol_list {
                    for local_symbol in local_reactant_list {
                        
                        // build the rate -
                        buffer+="*\(local_symbol)"
                    }
                    
                    // add a new line;
                    buffer+=";\n"
                }
            }
        }
        
        // return -
        return buffer
    }
}
