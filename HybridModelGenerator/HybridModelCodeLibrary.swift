//
//  HybridModelCodeLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/23/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String
}

class HybridModelCodeLibrary: NSObject {

}

class KineticsOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function kinetics_vector = Kinetics(x,t,DFIN)\n"
        buffer+="\n"
        buffer+="return"
        
        // return -
        return buffer
    }
}


class ControlOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function control_vector = Control(x,t,rate_vector,DFIN)\n"
        buffer+="\n"
        buffer+="\t% Initialize control_vector - \n"
        buffer+="\tnumber_of_rates = length(rate_vector);\n"
        buffer+="\tcontrol_vector = ones(number_of_rates,1);\n"
        buffer+="\n"
        buffer+="\t% Alias the state vector - \n"
        
        // iterate through the model context -
        let state_array = modelContext.state_symbol_array
        var state_index = 1
        for state_symbol in state_array {
            
            buffer+="\t"
            buffer+=state_symbol
            buffer+="\t=\t"
            buffer+="x(\(state_index));\n"
            
            // update the index -
            state_index++
        }
        
        
        buffer+="return"
        
        // return -
        return buffer
    }
}


class BalanceEquationsOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function DXDT = BalanceEquations(x,t,DFIN)\n"
        buffer+="\n"
        buffer+="return"
        
        // return -
        return buffer
    }
}


class SolveBalanceEquationsOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function [TSIM,X] = SolveBalanceEquations(TSTART,TSTOP,Ts,DFIN)\n"
        buffer+="\n"
        buffer+="return"
        
        // return -
        return buffer
    }
}

class DataFileOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
     
        // declarations -
        var buffer:String = ""
        
        buffer+="function DF = DataFile(TSTART,TSTOP,Ts,INDEX)\n"
        buffer+="\n"
        buffer+="\t% Set the initial condition - \n"
        buffer+="\tIC_ARRAY = [\n";
        
        // fill in the IC_ARRAY -
        let ordered_state_symbol_array = modelContext.state_symbol_array
        let state_model_dictionary = modelContext.state_model_dictionary!
        var counter = 1
        for state_symbol in ordered_state_symbol_array {
            
            // get the state_model -
            let state_model_object = state_model_dictionary[state_symbol]
            
            // Get the default value -
            let default_value:Double = state_model_object!.default_value!
            
            // write the record -
            buffer+="\t\t\(default_value)\t%\t\(state_symbol)\t\(counter)\n"
            
            // update the counter -
            counter++
        }
        
        buffer+="\t];\n"
        buffer+="\n"
        buffer+="\t% - DO NOT EDIT BELOW THIS LINE ------------------------------ \n"
        buffer+="\tDF.INITIAL_CONDITION_VECTOR = IC_ARRAY;\n"
        buffer+="\t% - DO NOT EDIT ABOVE THIS LINE ------------------------------ \n"
        buffer+="return"
        
        // return -
        return buffer
    }
}
