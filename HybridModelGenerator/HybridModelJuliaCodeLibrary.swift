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

class ControlJuliaStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function Control(t,x,rate_vector,metabolic_rate_vector,DF)\n"
        buffer+="\n"
        buffer+="\t# Initialize control_vector - \n"
        buffer+="\tnumber_of_rates = length(rate_vector);\n"
        buffer+="\tnumber_of_metabolic_rates = length(metabolic_rate_vector);\n"
        buffer+="\tcontrol_vector_gene_expression = ones(Float64,(number_of_rates,1));\n"
        buffer+="\tcontrol_vector_metabolism = ones(Float64,(number_of_metabolic_rates,1));\n"
        buffer+="\n"
        buffer+="\t# Get the parameter_vector - \n"
        buffer+="\tgene_expression_parameter_vector = DF[\"GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR\"];\n"
        buffer+="\tmetabolic_parameter_vector = DF[\"METABOLIC_CONTROL_PARAMETER_VECTOR\"];\n"
        buffer+="\n"
        buffer+="\t# Alias the state vector - \n"
        
        // iterate through the model context -
        let state_array = modelContext.state_symbol_array
        var state_index = 1
        for state_symbol in state_array {
            
            buffer+="\t"
            buffer+=state_symbol
            buffer+="\t=\t"
            buffer+="x[\(state_index)];\n"
            
            // update the index -
            state_index++
        }
        
        buffer+="\n"
        buffer+="\t# Formulate the gene expression control vector \n"
        
        
        
        // Analyze the gene expession control matrix -
        let gene_expression_control_matrix = modelContext.gene_expression_control_matrix!
        let gene_expression_effector_array = modelContext.gene_expression_effector_array!
        let gene_expression_output_array = modelContext.gene_expression_output_array!
        
        // How many effectors, and outputs do we have?
        let number_of_effectors = gene_expression_control_matrix.rows
        let number_of_outputs = gene_expression_control_matrix.columns
        var parameter_counter = 1;
        var control_term_counter = 1;
        
        buffer+="\t# Default value for all gene expression control terms is 0 \n"
        
        for output_symbol in gene_expression_output_array {
            
            // put in default value -
            buffer+="\tcontrol_vector_gene_expression[\(control_term_counter)] = 0.0;\n"
            
            // update the counter -
            control_term_counter = control_term_counter + 2
        }
        
        buffer+="\n"
        // ok, compute the corrections -
        // reset the counter -
        control_term_counter = 1
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
                    buffer+="\t# Control term  output:\(output_symbol)\n"
                    
                    // zero out f_vector -
                    buffer+="\tf_vector = Float64[];\n"
                    
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
                    let alpha_string = "\talpha_\(output_symbol)_\(effector_symbol) = gene_expression_parameter_vector[\(parameter_counter)]"
                    
                    // update the parameter counter -
                    parameter_counter++
                    
                    // Generate the order string -
                    let order_string = "\torder_\(output_symbol)_\(effector_symbol) = gene_expression_parameter_vector[\(parameter_counter)]"
                    
                    // Update the parameter counter -
                    parameter_counter++
                    
                    // ok, we have a + term -
                    // Write a comment -
                    buffer+=alpha_string+";\n"
                    buffer+=order_string+";\n"
                    
                    // Write the transfer function -
                    buffer+="\ttmp_value = "
                    buffer+="(alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol))/("
                    buffer+="1+alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol));\n"
                    buffer+="\tpush!(f_vector,tmp_value);\n\n"
                }
                else if (connection_code<0){
                    
                    // Generate the alpha string -
                    let alpha_string = "\talpha_\(output_symbol)_\(effector_symbol) = gene_expression_parameter_vector[\(parameter_counter)]"
                    
                    // update the parameter counter -
                    parameter_counter++
                    
                    // Generate the order string -
                    let order_string = "\torder_\(output_symbol)_\(effector_symbol) = gene_expression_parameter_vector[\(parameter_counter)]"
                    
                    // Update the parameter counter -
                    parameter_counter++
                    
                    // ok, we have a + term -
                    // Write a comment -
                    
                    buffer+=alpha_string+";\n"
                    buffer+=order_string+";\n"
                    
                    // Write the transfer function -
                    buffer+="\ttmp_value = 1 - "
                    buffer+="alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol)/("
                    buffer+="1+alpha_\(output_symbol)_\(effector_symbol)*\(effector_symbol)^order_\(output_symbol)_\(effector_symbol));\n"
                    buffer+="\tpush!(f_vector,tmp_value);\n\n"
                    
                    // direction is negative -
                    direction_flag = Direction.NEGATIVE
                }
            }
            
            if (gene_expression_control_matrix.isColumnAllZeros(col_index) == false) {
                
                // ok, when I get here, I've constructed the transfer function terms
                // apply the integration rule -
                buffer+="\tcontrol_vector_gene_expression[\(control_term_counter)] = "
                
                // which direction do we have?
                if (direction_flag == Direction.POSITIVE){
                    buffer+="maximum(f_vector);\n"
                }
                else {
                    buffer+="minimum(f_vector);\n"
                }
            }
            
            // update the counter -
            control_term_counter = control_term_counter + 2
            
            // add a space -
            buffer+="\n"
        }
        
        
        buffer+="\n"
        buffer+="\t# Formulate the metabolic control vector - \n"
        
        // get the metabolic control data from the context -
        parameter_counter = 1
        if let metabolic_control_array:Matrix = modelContext.metabolic_control_table,
            metabolic_control_target_array = modelContext.metabolic_control_target_symbol_array,
            metabolic_control_effector_array = modelContext.metabolic_control_effector_symbol_array {
                
                // ok, we have all the required data, generate the metabolic control term -
                for local_target_symbol in metabolic_control_target_array {
                    
                    // Lets assume by default we have a 'positive' TF -
                    var direction_flag:Direction = Direction.POSITIVE
                    
                    if let index_of_target_symbol = find(metabolic_control_target_array,local_target_symbol) {
                        
                        // Write the comment -
                        buffer+="\t# Metabolic control term target:\(local_target_symbol)\n"
                        buffer+="\tf_vector = Float64[];\n"
                        
                        var local_control_term_counter = 1
                        for local_effector_symbol in metabolic_control_effector_array {
                            
                            if let index_of_effector_symbol = find(metabolic_control_effector_array,local_effector_symbol) {
                                
                                // get the connection code -
                                let connection_code = metabolic_control_array[index_of_effector_symbol,index_of_target_symbol]
                                if (connection_code>0){
                                    
                                    // Generate the alpha string -
                                    let alpha_string = "\talpha_\(local_target_symbol)_\(local_effector_symbol) = metabolic_parameter_vector[\(parameter_counter)]"
                                    
                                    // update the parameter counter -
                                    parameter_counter++
                                    
                                    // Generate the order string -
                                    let order_string = "\torder_\(local_target_symbol)_\(local_effector_symbol) = metabolic_parameter_vector[\(parameter_counter)]"
                                    
                                    // Update the parameter counter -
                                    parameter_counter++
                                    
                                    // ok, we have a + term -
                                    // Write a comment -
                                    buffer+=alpha_string+";\n"
                                    buffer+=order_string+";\n"
                                    
                                    // Write the transfer function -
                                    buffer+="\ttmp_value = "
                                    buffer+="(alpha_\(local_target_symbol)_\(local_effector_symbol)*\(local_effector_symbol)^order_\(local_target_symbol)_\(local_effector_symbol))/("
                                    buffer+="1+alpha_\(local_target_symbol)_\(local_effector_symbol)*\(local_effector_symbol)^order_\(local_target_symbol)_\(local_effector_symbol));\n"
                                    buffer+="\tpush!(f_vector,tmp_value);\n\n"
                                }
                                else if (connection_code<0){
                                    
                                    // Generate the alpha string -
                                    let alpha_string = "\talpha_\(local_target_symbol)_\(local_effector_symbol) = metabolic_parameter_vector[\(parameter_counter)]"
                                    
                                    // update the parameter counter -
                                    parameter_counter++
                                    
                                    // Generate the order string -
                                    let order_string = "\torder_\(local_target_symbol)_\(local_effector_symbol) = metabolic_parameter_vector[\(parameter_counter)]"
                                    
                                    // Update the parameter counter -
                                    parameter_counter++
                                    
                                    // ok, we have a + term -
                                    // Write a comment -
                                    buffer+=alpha_string+";\n"
                                    buffer+=order_string+";\n"
                                    
                                    // Write the transfer function -
                                    buffer+="\ttmp_value = 1 - "
                                    buffer+="(alpha_\(local_target_symbol)_\(local_effector_symbol)*\(local_effector_symbol)^order_\(local_target_symbol)_\(local_effector_symbol))/("
                                    buffer+="1+alpha_\(local_target_symbol)_\(local_effector_symbol)*\(local_effector_symbol)^order_\(local_target_symbol)_\(local_effector_symbol));\n"
                                    buffer+="\tpush!(f_vector,tmp_value);\n\n"
                                    
                                    // update the local counter -
                                    local_control_term_counter++
                                    
                                    // we have a negative term -
                                    direction_flag = Direction.NEGATIVE
                                }
                            } // find effector find
                        } // end effector for
                    } // end target find
                    
                    // need to figure out the order ...
                    var reaction_index = 1
                    if let local_metabolic_reaction_array = modelContext.metabolic_reaction_array {
                        
                        for reaction_wrapper in local_metabolic_reaction_array {
                            
                            // get the catalyst symbol -
                            if let local_catalyst_symbol = reaction_wrapper.catalyst_symbol where (reaction_wrapper.isModelSymbolTheCatalyst(local_target_symbol))  {
                                
                                // get the reaction index -
                                reaction_index = reaction_wrapper.reaction_index + 1
                                
                                // write the control line -
                                buffer+="\tcontrol_vector_metabolism[\(reaction_index)] = "
                            }
                        }
                    }
                    
                    // which direction do we have?
                    if (direction_flag == Direction.POSITIVE){
                        buffer+="\tmaximum(f_vector);\n"
                    }
                    else {
                        buffer+="\tminimum(f_vector);\n"
                    }
                    
                    // add a new line -
                    buffer+="\n"
                } // end target for
        }
        
        
        
        buffer+="\treturn (control_vector_gene_expression, control_vector_metabolism)\n"
        buffer+="end"
        
        // return -
        return buffer
    }
}


class SolveBalanceEquationsJuliaStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="# Include statements - \n"
        buffer+="include(\"DataFile.jl\")\n"
        buffer+="include(\"Balances.jl\")\n"
        buffer+="using Sundials\n"
        buffer+="\n"
        
        buffer+="function SolveBalanceEquations(TSTART,TSTOP,Ts,DF)\n"
        buffer+="\n"
        
        buffer+="\t# Do we have a modified data dictionary? - \n"
        buffer+="\tif (length(DF) == 0)\n"
        buffer+="\t\tDFIN = DataFile(TSTART,TSTOP,Ts,-1);\n"
        buffer+="\telse\n"
        buffer+="\t\tDFIN = DF;\n"
        buffer+="\tend\n"
        buffer+="\n"
        buffer+="\t# Setup the simulation time scale - \n"
        buffer+="\tTSIM = [TSTART:Ts:TSTOP];\n"
        buffer+="\n"
        buffer+="\t# Grab the initial conditions from the data dictionary -\n"
        buffer+="\tinitial_condition_vector = DFIN[\"INITIAL_CONDITION_VECTOR\"];\n"
        buffer+="\n"
        buffer+="\t# Setup and call the ODE solver - \n"
        buffer+="\tfbalances(t,y,ydot) = Balances(t,y,ydot,DFIN);\n"
        buffer+="\tX = Sundials.cvode(fbalances,initial_condition_vector,TSIM);\n"
        buffer+="\n"
        buffer+="\treturn (TSIM,X);\n"
        buffer+="end"
        
        // return -
        return buffer
    }
}

class BalanceEquationsJuliaStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="# Include statements - \n"
        buffer+="include(\"Kinetics.jl\")\n"
        buffer+="include(\"Control.jl\")\n"
        buffer+="\n"
        
        buffer+="function Balances(t,x,dxdt_vector,DF)\n"
        buffer+="\n"
        
        
        buffer+="\t# Alias the state vector - \n"
    
        // iterate through the model context -
        let state_array = modelContext.state_symbol_array
        var state_index = 1
        for state_symbol in state_array {
            
            buffer+="\t"
            buffer+=state_symbol
            buffer+="\t=\t"
            buffer+="x[\(state_index)];\n"
            
            // update the index -
            state_index++
        }
        
        buffer+="\n"
        
        buffer+="\t# Define the rate_vector - \n"
        buffer+="\t(gene_expression_rate_vector, metabolic_rate_vector) = Kinetics(t,x,DF);\n"
        buffer+="\n"
        
        buffer+="\t# Define the control_vector - \n"
        buffer+="\t(gene_expression_control_vector, metabolic_control_vector) = Control(t,x,gene_expression_rate_vector,metabolic_rate_vector,DF);\n"
        buffer+="\n"
        
        buffer+="\t# Correct the gene expression rate vector - \n"
        buffer+="\tgene_expression_rate_vector = gene_expression_rate_vector.*gene_expression_control_vector;\n"
        buffer+="\n"
        
        buffer+="\t# Correct the metabolic rate vector - \n"
        buffer+="\tmetabolic_rate_vector = metabolic_rate_vector.*metabolic_control_vector;\n"
        buffer+="\n"
        
        buffer+="\t# Define the dxdt_vector - \n"
        
        // Get the symbol array -
        let state_symbol_array = modelContext.state_symbol_array
        let state_model_dictionary = modelContext.state_model_dictionary!
        let stoichiometric_matrix = modelContext.metabolic_stoichiometric_matrix!
        
        // Get data from the context -
        var species_counter = 1
        var rate_counter = 1
        var metabolite_counter = 0
        for state_symbol in state_symbol_array {
            
            // lookup state_model -
            let state_model = state_model_dictionary[state_symbol]!
            
            
            // ok, is this a dynamic state, or a constant state -
            if (state_model.state_role == RoleDescriptor.DYNAMIC){
                
                // ok, we have a dynamic species ... what type is it?
                let state_type = state_model.state_type!
                if (state_type == TypeDescriptor.mRNA){
                    buffer+="\tdxdt_vector[\(species_counter++)] = gene_expression_rate_vector[\(rate_counter++)] - gene_expression_rate_vector[\(rate_counter++)] - growth_rate*\(state_symbol)\t;\t# \(state_symbol)\n"
                }
                else if (state_type == TypeDescriptor.PROTIEN){
                    buffer+="\tdxdt_vector[\(species_counter++)] = gene_expression_rate_vector[\(rate_counter++)] - gene_expression_rate_vector[\(rate_counter++)] - growth_rate*\(state_symbol)\t;\t# \(state_symbol)\n"
                }
                else if (state_type == TypeDescriptor.OTHER){
                    buffer+="\tdxdt_vector[\(species_counter++)] = -growth_rate*\(state_symbol)\t;\t# \(state_symbol)\n"
                }
                else if (state_type == TypeDescriptor.METABOLITE){
                    
                    // Get the state symbol -
                    let state_symbol = state_model.state_symbol_string
                    
                    // species line -
                    buffer+="\tdxdt_vector[\(species_counter++)] = "
                    
                    // ok, so we have a legit symbol, go through the st matrix -
                    let number_of_reactions = stoichiometric_matrix.columns
                    for var reaction_index = 0;reaction_index<number_of_reactions;reaction_index++ {
                        
                        // get stcoeff -
                        let stcoeff = stoichiometric_matrix[metabolite_counter,reaction_index]
                        if (stcoeff != 0.0){
                            
                            // Add a leading +
                            if (reaction_index>0 && stcoeff>0){
                                buffer+="+"
                            }
                            
                            buffer+="\(stcoeff)*metabolic_rate_vector[\(reaction_index+1)]"
                        }
                    }
                    
                    // add new line -
                    buffer+="-growth_rate*\(state_symbol)\t;\t# \(state_symbol)\n"
                    
                    // update the metabolite counter -
                    metabolite_counter++
                }
            }
            else if (state_model.state_role == RoleDescriptor.CONSTANT){
                buffer+="\tdxdt_vector[\(species_counter++)] = 0.0\t;\t# \(state_symbol)\n"
            }
        }
        
        buffer+="\n"
        buffer+="\treturn dxdt_vector;\n"
        buffer+="end"
        
        // return -
        return buffer
    }
}


class DataFileJuliaStrategy:CodeStrategy {
    
    func execute(modelContext:HybridModelContext) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="function DataFile(TSTART,TSTOP,Ts,INDEX)\n"
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
        buffer+="\tGENE_EXPRESSION_CONTROL_PARAMETER_VECTOR = Float64[]\n"
        
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
                    buffer+="\tpush!(GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR,0.1)\t"
                    buffer+="#\t gain parameter => effector:\(effector_symbol)\touput_symbol:\(output_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                    
                    // update parameter counter -
                    parameter_counter++
                    
                    // Reaction order parameter -
                    buffer+="\tpush!(GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR,1.0)\t"
                    buffer+="#\t reaction order parameter => effector:\(effector_symbol)\touput_symbol:\(output_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                    
                    // update parameter counter -
                    parameter_counter++
                }
            }
        }
        
        buffer+="\n"
        buffer+="\t# Setup the *gene expression* parameter array - \n"
        buffer+="\tGENE_EXPRESSION_KINETIC_PARAMETER_VECTOR = Float64[]\n"
        
        // ok, so have gene expression processes, and potentially biochemical processes -
        // mRNA parameters, (alpha,beta), protein (alpha,beta) for now -
        let mRNA_array = modelContext.gene_expression_output_array!
        let protein_array = modelContext.translation_output_array!
        let central_dogma_array = mRNA_array+protein_array
        
        // Reset the parameter counter, and generate default values for the expression, translation
        // parameters -
        parameter_counter = 1
        for symbol in central_dogma_array {
            
            buffer+="\tpush!(GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR,0.1)\t"
            buffer+="#\t alpha_\(symbol) \(parameter_counter++)\n"
            buffer+="\tpush!(GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR,0.01)\t"
            buffer+="#\t beta_\(symbol) \(parameter_counter++)\n"
        }
        buffer+="\n"
        
        // ok, we need to put in the metabolic kinetic parameters if we have them -
        buffer+="\t# Setup the *metabolic* kinetic parameter array - \n"
        buffer+="\tMETABOLIC_KINETIC_PARAMETER_VECTOR = Float64[]\n"
        var metabolic_parameter_counter = 1
        if let metabolic_reaction_model_array = modelContext.metabolic_reaction_array {
            
            for rate_model in metabolic_reaction_model_array {
                
                // get parameter array -
                let local_parameter_array = rate_model.generateParameterSymbolArray()
                for parameter_symbol in local_parameter_array {
                    
                    // write the line -
                    buffer+="\tpush!(METABOLIC_KINETIC_PARAMETER_VECTOR,1.0)\t"
                    buffer+="#\t\(parameter_symbol) \(metabolic_parameter_counter++)\n"
                }
            }
        }
        
        buffer+="\n"
        
        // ok, so we need to generate the *control parameters* for metabolism -\
        buffer+="\t# Setup the *metabolic* control parameter array - \n"
        buffer+="\tMETABOLIC_CONTROL_PARAMETER_VECTOR = Float64[]\n"
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
                                    buffer+="\tpush!(METABOLIC_CONTROL_PARAMETER_VECTOR,0.1)\t"
                                    buffer+="#\t gain parameter => effector:\(local_effector_symbol)\touput_symbol:\(local_target_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                                    
                                    // update parameter counter -
                                    parameter_counter++
                                    
                                    // Reaction order parameter -
                                    buffer+="\tpush!(METABOLIC_CONTROL_PARAMETER_VECTOR,1.0)\t"
                                    buffer+="#\t reaction order parameter => effector:\(local_effector_symbol)\touput_symbol:\(local_target_symbol)\t\(parameter_counter)\tconnection_code:\(connection_code)\n"
                                    
                                    // update parameter counter -
                                    parameter_counter++
                                    
                                }
                            }
                        }
                    }
                }
        }
        
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

        // Get data from the context -
        var parameter_counter = 1
        var rate_counter = 1
        for state_symbol in state_symbol_array {
            
            // lookup state_model -
            let state_model = state_model_dictionary[state_symbol]!
            
            // ok, is this a dynamic state, or a constant state -
            if (state_model.state_role == RoleDescriptor.DYNAMIC){
                
                // ok, we are a dyamic state, what type of state do we have?
                let state_type = state_model.state_type!
                if (state_type == TypeDescriptor.mRNA){
                    
                    // put a comment line -
                    buffer+="\t# species_symbol: \(state_symbol) \n"
                    
                    // if we have an mRNA state, then we need to create expression, dilution, and degrdation rates -
                    
                    // mRNA should have a gene precursor?
                    if let precursor_symbol = state_model.state_precursor_symbol_array?.last {
                        buffer+="\tpush!(gene_expression_rate_vector, gene_expression_parameter_vector[\(parameter_counter++)]*RNAP*\(precursor_symbol));\t #\(rate_counter++)\n"
                    }
                    else {
                        buffer+="\tpush!(gene_expression_rate_vector, gene_expression_parameter_vector[\(parameter_counter++)]*RNAP);\t #\(rate_counter++)\n"
                    }
                    
                    buffer+="\tpush!(gene_expression_rate_vector,gene_expression_parameter_vector[\(parameter_counter++)]*\(state_symbol));\t #\(rate_counter++)\n"
                    
                    // new line -
                    buffer+="\n"
                }
                else if (state_type == TypeDescriptor.PROTIEN){
                    
                    // put a comment line -
                    buffer+="\t# species_symbol: \(state_symbol) \n"
                    
                    // if we have an protein state, then we need to create expression, dilution, and degrdation rates -
                    
                    // protein should have a mRNA precursor
                    if let precursor_symbol = state_model.state_precursor_symbol_array?.last {
                        buffer+="\tpush!(gene_expression_rate_vector, gene_expression_parameter_vector[\(parameter_counter++)]*RIBOSOME*\(precursor_symbol));\t #\(rate_counter++)\n"
                    }
                    else {
                        buffer+="\tpush!(gene_expression_rate_vector,gene_expression_parameter_vector[\(parameter_counter++),1]*RIBOSOME);\t #\(rate_counter++)\n"
                    }
                    
                    buffer+="\tpush!(gene_expression_rate_vector,gene_expression_parameter_vector[\(parameter_counter++)]*\(state_symbol));\t #\(rate_counter++)\n"
                    
                    // new line -
                    buffer+="\n"
                }
                else if (state_type == TypeDescriptor.OTHER) {
                    
                    // put a comment line -
                    buffer+="\t# species_symbol: \(state_symbol) \n"
                    
                    // if we have a other state, and we are dynamic, this means we will add somehow and dilute -
                    buffer+="\tpush!(gene_expression_rate_vector, growth_rate*\(state_symbol));\t #\(rate_counter++)\n"
                    
                    // new line -
                    buffer+="\n"
                }
            }
        }
        
        buffer+="\n"
        buffer+="\t# Define the metabolic reaction rates - \n"
        
        // ok, now lets do the metabolic rates -
        var metabolic_reaction_index = 1
        if let metabolic_reaction_array = modelContext.metabolic_reaction_array {
            
            for metabolic_reaction in metabolic_reaction_array {
                
                buffer+="\tpush!(metabolic_rate_vector,"
                buffer+=metabolic_reaction.generateReactionString()
                buffer+=");\t #\(metabolic_reaction_index++)\n"
            }
        }
        
        
        buffer+="\treturn (gene_expression_rate_vector,metabolic_rate_vector)\n"
        buffer+="end\n"
        
        // return the buffer =
        return buffer
    }
}
