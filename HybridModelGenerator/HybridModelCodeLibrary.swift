//
//  HybridModelCodeLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/23/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum Direction {
    case POSITIVE
    case NEGATIVE
}

protocol CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String
}

class HybridModelCodeLibrary: NSObject {

}

class KineticsOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        let state_symbol_array = modelContext.state_symbol_array
        let state_model_dictionary = modelContext.state_model_dictionary!
        
        buffer+="function rate_vector = Kinetics(t,x,DF)\n"
        buffer+="\n"
        buffer+="\t% Initialize empty rate_vector - \n"
        buffer+="\trate_vector = [];\n"
        buffer+="\n"
        buffer+="\t% Get the kinetic_parameter_vector - \n"
        buffer+="\tkinetic_parameter_vector = DF.KINETIC_PARAMETER_VECTOR;\n"
        buffer+="\n"
        
        buffer+="\t% Alias the state vector - \n"
        
        // iterate through the model context -
        var state_index = 1
        for state_symbol in state_symbol_array {
            
            buffer+="\t"
            buffer+=state_symbol
            buffer+="\t=\t"
            buffer+="x(\(state_index));\n"
            
            // update the index -
            state_index++
        }
        
        buffer+="\n"
        
        // Get data from the context -
        var parameter_counter = 1
        var rate_counter = 1
        for state_symbol in state_symbol_array {
            
            // lookup state_model - 
            let state_model = state_model_dictionary[state_symbol]!
            
            // ok, is this a dynamic state, or a constant state -
            if (state_model.state_role == RoleDescriptor.DYNAMIC){
            
                // put a comment line -
                buffer+="\t% species_symbol: \(state_symbol) \n"
                
                // ok, we are a dyamic state, what type of state do we have?
                let state_type = state_model.state_type!
                if (state_type == TypeDescriptor.mRNA){
                    
                    // if we have an mRNA state, then we need to create expression, dilution, and degrdation rates -
                    
                    // mRNA should have a gene precursor?
                    if let precursor_symbol = state_model.state_precursor_symbol_array?.last {
                        buffer+="\trate_vector(\(rate_counter++),1) = kinetic_parameter_vector(\(parameter_counter++),1)*RNAP*\(precursor_symbol);\n"
                    }
                    else {
                        buffer+="\trate_vector(\(rate_counter++),1) = kinetic_parameter_vector(\(parameter_counter++),1)*RNAP;\n"
                    }
                    
                    buffer+="\trate_vector(\(rate_counter++),1) = kinetic_parameter_vector(\(parameter_counter++),1)*\(state_symbol);\n"
                    buffer+="\trate_vector(\(rate_counter++),1) = growth_rate*\(state_symbol);\n"
                    
                    // new line -
                    buffer+="\n"
                }
                else if (state_type == TypeDescriptor.PROTIEN){
                    
                    // if we have an protein state, then we need to create expression, dilution, and degrdation rates -
                    
                    // protein should have a mRNA precursor 
                    if let precursor_symbol = state_model.state_precursor_symbol_array?.last {
                        buffer+="\trate_vector(\(rate_counter++),1) = kinetic_parameter_vector(\(parameter_counter++),1)*RIBOSOME*\(precursor_symbol);\n"
                    }
                    else {
                        buffer+="\trate_vector(\(rate_counter++),1) = kinetic_parameter_vector(\(parameter_counter++),1)*RIBOSOME;\n"
                    }
                    
                    buffer+="\trate_vector(\(rate_counter++),1) = kinetic_parameter_vector(\(parameter_counter++),1)*\(state_symbol);\n"
                    buffer+="\trate_vector(\(rate_counter++),1) = growth_rate*\(state_symbol);\n"
                    
                    // new line -
                    buffer+="\n"
                }
                else if (state_type == TypeDescriptor.METABOLITE) {
                    
                    // if we have a metabolite state, then we need to create expression, dilution, and degrdation rates -
                    
                    
                    
                    // new line -
                    buffer+="\n"
                    
                }
                else if (state_type == TypeDescriptor.OTHER) {
                    
                    // if we have a other state, and we are dynamic, this means we will add somehow and dilute -
                    buffer+="\trate_vector(\(rate_counter++),1) = growth_rate*\(state_symbol);\n"
                    
                    // new line -
                    buffer+="\n"
                }
            }
        }
        
        buffer+="return\n"
        
        // return -
        return buffer
    }
}


class ControlOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function control_vector = Control(t,x,rate_vector,DF)\n"
        buffer+="\n"
        buffer+="\t% Initialize control_vector - \n"
        buffer+="\tnumber_of_rates = length(rate_vector);\n"
        buffer+="\tcontrol_vector = ones(number_of_rates,1);\n"
        buffer+="\n"
        buffer+="\t% Get the parameter_vector - \n"
        buffer+="\tparameter_vector = DF.CONTROL_PARAMETER_VECTOR;\n"
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
        var control_term_counter = 1;
        
        for var col_index = 0;col_index<number_of_outputs;col_index++ {
            
            // Lets assume by default we have a 'positive' TF -
            var direction_flag:Direction = Direction.POSITIVE
            
            // get output symbol -
            let output_symbol = gene_expression_output_array[col_index]
            var local_term_counter = 1
            
            // scan down the col - are *any* of the row neq 0?
            for var scan_index = 0;scan_index<number_of_effectors;scan_index++ {
                
                let connection_code = gene_expression_control_matrix[scan_index,col_index]
                
                if (connection_code != 0){
                    let effector_symbol = gene_expression_effector_array[scan_index]
                    buffer+="\t% Control term  output:\(output_symbol)\n"
                    
                    // zero out f_vector -
                    buffer+="\tf_vector = 0;\n"

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
                    buffer+="\tf_vector(\(local_term_counter),1) = "
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
                    buffer+="\tf_vector(\(local_term_counter),1) = 1 - "
                    buffer+="alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol)/("
                    buffer+="1+alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol));\n"
                    
                    // update the local counter -
                    local_term_counter++
                    
                    // direction is negative -
                    direction_flag = Direction.NEGATIVE
                }
            }
            
            // ok, when I get here, I've constructed the transfer function terms
            // apply the integration rule -
            buffer+="\tcontrol_vector(\(control_term_counter),1) = "
            
            // update the counter -
            control_term_counter = control_term_counter + 3
            
            // which direction do we have?
            if (direction_flag == Direction.POSITIVE){
                buffer+="max(f_vector);\n"
            }
            else {
                buffer+="min(f_vector);\n"
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
        
        buffer+="function dxdt_vector = Balances(x,t,DF)\n"
        buffer+="\n"
        
        buffer+="\t% Initialize dxdt_vector - \n"
        buffer+="\tnumber_of_states = length(x);\n"
        buffer+="\tdxdt_vector = zeros(number_of_states,1);\n"
        buffer+="\n"
        
        buffer+="\t% Define the rate_vector - \n"
        buffer+="\tbare_rate_vector = Kinetics(t,x,DF);\n"
        buffer+="\n"
        
        buffer+="\t% Define the control_vector - \n"
        buffer+="\tcontrol_vector = Control(t,x,bare_rate_vector,DF);\n"
        buffer+="\n"
        
        buffer+="\t% Correct the bare_rate_vector - \n"
        buffer+="\trate_vector = bare_rate_vector.*control_vector;\n"
        buffer+="\n"
        
        buffer+="\t% Define the dxdt_vector - \n"
        
        // Get the symbol array -
        let state_symbol_array = modelContext.state_symbol_array
        let state_model_dictionary = modelContext.state_model_dictionary!
        
        // Get data from the context -
        var species_counter = 1
        var rate_counter = 1
        for state_symbol in state_symbol_array {
            
            // lookup state_model -
            let state_model = state_model_dictionary[state_symbol]!
            
            // ok, is this a dynamic state, or a constant state -
            if (state_model.state_role == RoleDescriptor.DYNAMIC){
            
                // ok, we have a dynamic species ... what type is it?
                let state_type = state_model.state_type!
                if (state_type == TypeDescriptor.mRNA){
                    buffer+="\tdxdt_vector(\(species_counter++),1) = rate_vector(\(rate_counter++),1) - rate_vector(\(rate_counter++),1) - rate_vector(\(rate_counter++),1)\t;\t% \(state_symbol)\n"
                }
                else if (state_type == TypeDescriptor.PROTIEN){
                    buffer+="\tdxdt_vector(\(species_counter++),1) = rate_vector(\(rate_counter++),1) - rate_vector(\(rate_counter++),1) - rate_vector(\(rate_counter++),1)\t;\t% \(state_symbol)\n"
                }
                else if (state_type == TypeDescriptor.OTHER){
                    buffer+="\tdxdt_vector(\(species_counter++),1) = -rate_vector(\(rate_counter++),1)\t;\t% \(state_symbol)\n"
                }
            }
            else if (state_model.state_role == RoleDescriptor.CONSTANT){
                buffer+="\tdxdt_vector(\(species_counter++),1) = 0.0\t;\t% \(state_symbol)\n"
            }
        }
        
        buffer+="\n"
        buffer+="return\n"
        
        // return -
        return buffer
    }
}


class SolveBalanceEquationsOctaveMStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function [TSIM,X] = SolveBalanceEquations(TSTART,TSTOP,Ts,DF)\n"
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
        buffer+="\tinitial_condition_vector = DFIN.INITIAL_CONDITION_VECTOR;\n"
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
        buffer+="\t];\n"
        
        buffer+="\n"
        buffer+="\t% Setup the *control* parameter array - \n"
        buffer+="\tCONTROL_PARAMETER_VECTOR = [\n"
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
        buffer+="\t% Setup the *kinetic* parameter array - \n"
        buffer+="\tKINETIC_PARAMETER_VECTOR = [\n"
        buffer+="\n"

        // ok, so have gene expression processes, and potentially biochemical processes -
        // mRNA parameters, (alpha,beta), protein (alpha,beta) for now -
        let mRNA_array = modelContext.gene_expression_output_array!
        let protein_array = modelContext.translation_output_array!
        let central_dogma_array = mRNA_array+protein_array
        
        // Reset the parameter counter, and generate default values for the expression, translation
        // parameters -
        parameter_counter = 1
        for symbol in central_dogma_array {
            
            buffer+="\t\t0.1\t;\t%\t alpha_\(symbol) \(parameter_counter++)\n"
            buffer+="\t\t0.01\t;\t%\t beta_\(symbol) \(parameter_counter++)\n"
            buffer+="\n"
        }
        
        buffer+="\t];\n"
        buffer+="\n"
        buffer+="\t% - DO NOT EDIT BELOW THIS LINE ------------------------------ \n"
        buffer+="\tDF.KINETIC_PARAMETER_VECTOR = KINETIC_PARAMETER_VECTOR;\n"
        buffer+="\tDF.CONTROL_PARAMETER_VECTOR = CONTROL_PARAMETER_VECTOR;\n"
        buffer+="\tDF.INITIAL_CONDITION_VECTOR = IC_ARRAY;\n"
        buffer+="\t% - DO NOT EDIT ABOVE THIS LINE ------------------------------ \n"
        buffer+="return"
        
        // return -
        return buffer
    }
}
