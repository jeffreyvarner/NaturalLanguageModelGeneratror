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
        
        buffer+="\n"
        
        // Analyze the gene expession control matrix -
        let gene_expression_control_matrix = modelContext.gene_expression_control_matrix!
        let gene_expression_effector_array = modelContext.gene_expression_effector_array!
        let gene_expression_output_array = modelContext.gene_expression_output_array!
        
        // How many effectors, and outputs do we have?
        let number_of_effectors = gene_expression_control_matrix.rows
        let number_of_outputs = gene_expression_control_matrix.columns
        var parameter_counter = 1;
        for var col_index = 0;col_index<number_of_outputs;col_index++ {
            
            // get output symbol -
            let output_symbol = gene_expression_output_array[col_index]
            var local_term_counter = 1
            
            // scan down the col - are *any* of the row neq 0?
            for var scan_index = 0;scan_index<number_of_effectors;scan_index++ {
                
                let connection_code = gene_expression_control_matrix[scan_index,col_index]
                
                if (connection_code != 0){
                    let effector_symbol = gene_expression_effector_array[scan_index]
                    buffer+="\t% Control term  output:\(output_symbol) effector:\(effector_symbol)\n"
                    
                    break
                }
            }
    
            
            for var row_index = 0;row_index<number_of_effectors;row_index++ {
                
                // Get the effector symbol -
                let effector_symbol = gene_expression_effector_array[row_index]
                
                // ok, do we have a connection?
                let connection_code = gene_expression_control_matrix[row_index,col_index]
                
                
                
                if (connection_code>0){
                    
                    // Generate the alpha string -
                    let alpha_string = "\talpha_\(output_symbol)_\(effector_symbol) = parameter_vector(\(parameter_counter))"
                    
                    // update the parameter counter -
                    parameter_counter++
                    
                    // Generate the order string -
                    let order_string = "\torder_\(output_symbol)_\(effector_symbol) = parameter_vector(\(parameter_counter))"
                    
                    // Update the parameter counter -
                    parameter_counter++
                    
                    // ok, we have a + term -
                    // Write a comment -
                    buffer+=alpha_string+";\n"
                    buffer+=order_string+";\n"
                    
                    // Write the transfer function -
                    buffer+="\tf_\(local_term_counter) = "
                    buffer+="(alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol))/("
                    buffer+="1+alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol));\n"
                    
                    // update the local counter -
                    local_term_counter++
                }
                else if (connection_code<0){
                 
                    // Generate the alpha string -
                    let alpha_string = "\talpha_\(output_symbol)_\(effector_symbol) = parameter_vector(\(parameter_counter))"
                    
                    // update the parameter counter -
                    parameter_counter++
                    
                    // Generate the order string -
                    let order_string = "\torder_\(output_symbol)_\(effector_symbol) = parameter_vector(\(parameter_counter))"
                    
                    // Update the parameter counter -
                    parameter_counter++
                    
                    // ok, we have a + term -
                    // Write a comment -
                    
                    buffer+=alpha_string+";\n"
                    buffer+=order_string+";\n"
                    
                    // Write the transfer function -
                    buffer+="\tf_\(local_term_counter) = 1 - "
                    buffer+="alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol)/("
                    buffer+="1+alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol));\n"
                    
                    // update the local counter -
                    local_term_counter++
                }
            }
            
            // add a space -
            buffer+="\n"
        }

        
        buffer+="return\n"
        
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
        
        buffer+="\tif (isempty(DF))\n"
        buffer+="\t\tDFIN = DataFile(TSTART,TSTOP,Ts,[]);\n"
        buffer+="\telse\n"
        buffer+="\t\tDFIN = DF;\n"
        buffer+="\tend\n"
        buffer+="\n"
        buffer+="\t% Simulation time scale - \n"
        buffer+="\tTSIM = TSTART:Ts:TSTOP;\n"
        buffer+="\n"
        buffer+="\t% Grab the initial conditions -\n"
        buffer+="\tinitial_condition_vector = DFIN.initial_condition_vector;\n"
        buffer+="\n"
        buffer+="\t% Setup call to ODE solver - \n"
        buffer+="\tfbalances = @(x,t)Balances(x,t,DFIN);\n"
        buffer+="\tX = lsode(fbalances,initial_condition_vector,TSIM);\n"
        buffer+="\n"
        buffer+="return\n"
        
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
            buffer+="\t\t\(default_value)\t;\t%\t\(state_symbol)\t\(counter)\n"
            
            // update the counter -
            counter++
        }
        
        buffer+="\n"
        buffer+="\t% Setup the parameter array - \n"
        buffer+="\tPARAMETER_ARRAY = [\n"
        buffer+="\n"
        
        // Analyze the gene expession control matrix -
        let gene_expression_control_matrix = modelContext.gene_expression_control_matrix!
        let gene_expression_effector_array = modelContext.gene_expression_effector_array!
        let gene_expression_output_array = modelContext.gene_expression_output_array!
        
        // How many effectors, and outputs do we have?
        let number_of_effectors = gene_expression_control_matrix.rows
        let number_of_outputs = gene_expression_control_matrix.columns
        var parameter_counter = 1;
        for var col_index = 0;col_index<number_of_outputs;col_index++ {
            
            // get output symbol -
            let output_symbol = gene_expression_output_array[col_index]
            
            for var row_index = 0;row_index<number_of_effectors;row_index++ {
                
                // Get the effector symbol -
                let effector_symbol = gene_expression_effector_array[row_index]
                
                // ok, do we have a connection?
                let connection_code = gene_expression_control_matrix[row_index,col_index]
                if (connection_code != 0){
                    
                    // ok, for each *non-zero* element we have a *two* parameters, and alpha and an order parameter -
                    // Gain parameter -
                    buffer+="\t\t0.1\t;\t%\t gain parameter => effector:\(effector_symbol)\touput_symbol:\(output_symbol)\t\(parameter_counter)\n"
                    
                    // update parameter counter -
                    parameter_counter++
                    
                    // Reaction order parameter -
                    buffer+="\t\t1.0\t;\t%\t reaction order parameter => effector:\(effector_symbol)\touput_symbol:\(output_symbol)\t\(parameter_counter)\n"
                    
                    // update parameter counter -
                    parameter_counter++
                    
                    // Add a new line =
                    buffer+="\n"
                }
            }
        }
        
        
        
        buffer+="\t];\n"
        buffer+="\n"
        buffer+="\t% - DO NOT EDIT BELOW THIS LINE ------------------------------ \n"
        buffer+="\tDF.PARAMETER_VECTOR = PARAMETER_ARRAY;\n"
        buffer+="\tDF.INITIAL_CONDITION_VECTOR = IC_ARRAY;\n"
        buffer+="\t% - DO NOT EDIT ABOVE THIS LINE ------------------------------ \n"
        buffer+="return"
        
        // return -
        return buffer
    }
}
