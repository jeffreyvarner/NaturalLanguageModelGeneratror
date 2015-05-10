//
//  HybridModelJuliaCodeLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/9/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class HybridModelJuliaCodeLibrary: NSObject {
    
    // make a bunch of static methods that return stuff -
    static func appendNewLineToBuffer(inout buffer:String) -> Void {
        buffer+="\n"
    }
    
    // build function header -
    
}

class DataFileJuliaStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function data_dictionary = DataFile(TSTART,TSTOP,Ts,INDEX)\n"
        buffer+="\n"
        buffer+="\t# Set the initial condition - \n"
        buffer+="\tIC_ARRAY = Float64[]\n"
        
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
            buffer+="\tpush!(IC_ARRAY,\(default_value))\t"
            buffer+="#\t\(state_symbol)\t\(counter)\n"
            
            // update the counter -
            counter++
        }
        
        buffer+="\n"
        buffer+="\t# Setup the *control* parameter array - \n"
        buffer+="\tGENE_EXPRESSION_CONTROL_PARAMETER_VECTOR = [\n"
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
                    buffer+="\t\t0.1\t;\t%\t gain parameter => effector:\(effector_symbol)\touput_symbol:\(output_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                    
                    // update parameter counter -
                    parameter_counter++
                    
                    // Reaction order parameter -
                    buffer+="\t\t1.0\t;\t%\t reaction order parameter => effector:\(effector_symbol)\touput_symbol:\(output_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                    
                    // update parameter counter -
                    parameter_counter++
                    
                    // Add a new line =
                    buffer+="\n"
                }
            }
        }
        
        buffer+="\t];\n"
        buffer+="\n"
        buffer+="\t# Setup the *gene expression* parameter array - \n"
        buffer+="\tGENE_EXPRESSION_KINETIC_PARAMETER_VECTOR = [\n"
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
        
        // ok, we need to put in the metabolic kinetic parameters if we have them -
        buffer+="\t# Setup the *metabolic* kinetic parameter array - \n"
        buffer+="\tMETABOLIC_KINETIC_PARAMETER_VECTOR = [\n"
        var metabolic_parameter_counter = 1
        if let metabolic_reaction_model_array = modelContext.metabolic_reaction_array {
            
            for rate_model in metabolic_reaction_model_array {
                
                // get parameter array -
                let local_parameter_array = rate_model.generateParameterSymbolArray()
                for parameter_symbol in local_parameter_array {
                    
                    // write the line -
                    buffer+="\t\t1.0\t;\t%\t\(parameter_symbol) \(metabolic_parameter_counter++)\n"
                }
            }
        }
        
        buffer+="\t];\n"
        buffer+="\n"
        
        // ok, so we need to generate the *control parameters* for metabolism -\
        buffer+="\t# Setup the *metabolic* control parameter array - \n"
        buffer+="\tMETABOLIC_CONTROL_PARAMETER_VECTOR = [\n"
        buffer+="\n"
        // get the metabolism control information -
        parameter_counter = 1
        if let metabolic_control_array:Matrix = modelContext.metabolic_control_table,
            metabolic_control_target_array = modelContext.metabolic_control_target_symbol_array,
            metabolic_control_effector_array = modelContext.metabolic_control_effector_symbol_array {
                
                // ok, we have all the required data, generate the metabolic control term -
                for local_target_symbol in metabolic_control_target_array {
                    
                    if let index_of_target_symbol = find(metabolic_control_target_array,local_target_symbol) {
                        
                        for local_effector_symbol in metabolic_control_effector_array {
                            
                            if let index_of_effector_symbol = find(metabolic_control_effector_array,local_effector_symbol) {
                                
                                // get the connection code -
                                let connection_code = metabolic_control_array[index_of_effector_symbol,index_of_target_symbol]
                                if (connection_code != 0){
                                    
                                    // ok, for each *non-zero* element we have a *two* parameters, and alpha and an order parameter -
                                    // Gain parameter -
                                    buffer+="\t\t0.1\t;\t%\t gain parameter => effector:\(local_effector_symbol)\touput_symbol:\(local_target_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                                    
                                    // update parameter counter -
                                    parameter_counter++
                                    
                                    // Reaction order parameter -
                                    buffer+="\t\t1.0\t;\t%\t reaction order parameter => effector:\(local_effector_symbol)\touput_symbol:\(local_target_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                                    
                                    // update parameter counter -
                                    parameter_counter++
                                    
                                    // Add a new line =
                                    buffer+="\n"
                                }
                            }
                        }
                    }
                }
        }
        
        buffer+="\t];\n"
        buffer+="\n"
        
        buffer+="\t# - DO NOT EDIT BELOW THIS LINE ------------------------------ \n"
        buffer+="\tdata_dictionary = Dict()\n"
        buffer+="\tdata_dictionary[\"GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR\"] = GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR\n"
        buffer+="\tdata_dictionary[\"METABOLIC_KINETIC_PARAMETER_VECTOR\"] = METABOLIC_KINETIC_PARAMETER_VECTOR\n"
        buffer+="\tdata_dictionary[\"GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR\"] = GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR\n"
        buffer+="\tdata_dictionary[\"METABOLIC_CONTROL_PARAMETER_VECTOR\"] = METABOLIC_CONTROL_PARAMETER_VECTOR\n"
        buffer+="\tdata_dictionary[\"INITIAL_CONDITION_VECTOR\"] = IC_ARRAY\n"
        buffer+="\t# - DO NOT EDIT ABOVE THIS LINE ------------------------------ \n"
        buffer+="\treturn data_dictionary\n"
        buffer+="end\n"
        
        // return -
        return buffer
    }
}

class KineticsJuliaStrategy:CodeStrategy {

    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer = ""
        let state_symbol_array = modelContext.state_symbol_array
        let state_model_dictionary = modelContext.state_model_dictionary!
        
        // ok, we need to create a function -
        buffer+="function Kinetics(t,x,DF)\n"
        
        // Add a new line -
        HybridModelJuliaCodeLibrary.appendNewLineToBuffer(&buffer)
        
        // initialize the rate vectors -
        buffer+="\t# Initialize empty *_rate_vectors - \n"
        buffer+="\tgene_expression_rate_vector = Float64[];\n"
        buffer+="\tmetabolic_rate_vector = Float64[];\n"
        buffer+="\n"
        
        // Get the parameter vectors -
        buffer+="\t# Get the parameter vectors from DF - \n"
        buffer+="\tgene_expression_parameter_vector = DF[\"GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR\"]\n"
        buffer+="\tmetabolic_parameter_vector = DF[\"METABOLIC_KINETIC_PARAMETER_VECTOR\"]\n"
        buffer+="\n"
        
        buffer+="\t# Alias the metabolic parameters - \n"
        var metabolic_parameter_counter = 1
        if let metabolic_reaction_model_array = modelContext.metabolic_reaction_array {
            
            for rate_model in metabolic_reaction_model_array {
                
                // get parameter array -
                let local_parameter_array = rate_model.generateParameterSymbolArray()
                for parameter_symbol in local_parameter_array {
                    
                    // write the line -
                    buffer+="\t\(parameter_symbol) = metabolic_parameter_vector[\(metabolic_parameter_counter++)];\n"
                }
            }
        }
        
        buffer+="\n"
        buffer+="\t# Alias the state vector - \n"
        
        // iterate through the model context -
        var state_index = 1
        for state_symbol in state_symbol_array {
            
            buffer+="\t"
            buffer+=state_symbol
            buffer+="\t=\t"
            buffer+="x[\(state_index)];\n"
            
            // update the index -
            state_index++
        }
        
        buffer+="\n"

        
        
        
        buffer+="\treturn (gene_expression_rate_vector,metabolic_rate_vector)\n"
        buffer+="end\n"
        
        // return the buffer =
        return buffer
    }
}
