//
//  JuliaLanguageStrategyLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol CodeGenerationStrategy {
    
    func execute(node:SyntaxTreeComponent) -> String
}


class JuliaLanguageStrategyLibrary: NSObject {

    // vars -
    static var my_input_url:NSURL?
    
    // make a bunch of static methods that return stuff -
    static func appendNewLineToBuffer(inout buffer:String) -> Void {
        buffer+="\n"
    }
    
    
    static func dispatchGenericTreeVisitorOnTreeWithTypeDictionary(root:SyntaxTreeComposite,visitorClassName:String) -> Any? {
        
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }
        
        // create visitor dictionary -
        var visitor_dictionary = [
            "BasalGeneExpressionKineticsFunctionSyntaxTreeVisitor" : BasalGeneExpressionKineticsFunctionSyntaxTreeVisitor.self
        ]
        
        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            if let class_value = visitor_dictionary[visitorClassName] {
                
                var tree_visitor = class_value(typeDictionary: _type_dictionary)
                for child_node in root.children_array {
                    child_node.accept(tree_visitor)
                }
                
                return tree_visitor.getSyntaxTreeVisitorData()
            }
        }
        
        return nil
    }
    
    static func extractGeneExpressionControlModel(root:SyntaxTreeComposite) -> Dictionary<String,Array<VLEMControlRelationshipProxy>>? {
    
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }

        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            var gene_expression_control_visitor = GeneExpressionControlModelSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(gene_expression_control_visitor)
            }
            
            return gene_expression_control_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,Array<VLEMControlRelationshipProxy>>
        }
        
        return nil
    }
    
    static func extractProteinTranslationKineticsList(root:SyntaxTreeComposite) -> [VLEMProxyNode]? {
        
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }
        
        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            // Build the transfer function tree visitor -
            var translation_kinetics_visitor = ProteinTranslationKineticsFunctionSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(translation_kinetics_visitor)
            }
            return translation_kinetics_visitor.getSyntaxTreeVisitorData() as? [VLEMProxyNode]
        }
        
        return nil
    }

    static func extractProteinDegradationKineticsList(root:SyntaxTreeComposite) -> [VLEMProxyNode]? {
        
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }
        
        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            // Build the transfer function tree visitor -
            var degradation_kinetics_visitor = ProteinDegradationKineticsFunctionSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(degradation_kinetics_visitor)
            }
            return degradation_kinetics_visitor.getSyntaxTreeVisitorData() as? [VLEMProxyNode]
        }
        
        return nil
    }

    
    static func extractMessengerRNADegradationKineticsList(root:SyntaxTreeComposite) -> [VLEMProxyNode]? {
    
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }

        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            // Build the transfer function tree visitor -
            var degradation_kinetics_visitor = MessengerRNADegradationineticsFunctionSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(degradation_kinetics_visitor)
            }
            return degradation_kinetics_visitor.getSyntaxTreeVisitorData() as? [VLEMProxyNode]
        }
        
        return nil
    }
    
    static func extractGeneExpressionKineticsList(root:SyntaxTreeComposite) -> [VLEMProxyNode]? {
        
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }
        
        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            // Build the transfer function tree visitor -
            var gene_expression_kinetics_visitor = GeneExpressionKineticsFunctionSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(gene_expression_kinetics_visitor)
            }
            return gene_expression_kinetics_visitor.getSyntaxTreeVisitorData() as? [VLEMProxyNode]
        }
        
        return nil
    }

    
    static func extractGeneExpressionRateList(root:SyntaxTreeComposite) -> [VLEMGeneExpressionRateProcessProxy]? {
        
        // get the list of rates involved in gene expression (includes degradation rates for both protein, and mRNA)
        var rate_visitor = GeneExpressionRateParameterSyntaxTreeVistor()
        for child_node in root.children_array {
            child_node.accept(rate_visitor)
        }
        
        return rate_visitor.getSyntaxTreeVisitorData() as? [VLEMGeneExpressionRateProcessProxy]
    }
    
    
    static func extractTargetList(root:SyntaxTreeComposite) -> [VLEMProxyNode]? {
    
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }
        
        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            // Build the transfer function tree visitor -
            var target_visitor = BiologicalTargetSymbolSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(target_visitor)
            }
            return target_visitor.getSyntaxTreeVisitorData() as? [VLEMProxyNode]
        }
        
        return nil
    }
    
    static func extractSpeciesList(root:SyntaxTreeComposite) -> [VLEMProxyNode]? {
        
        // Get the list of species using the vistor pattern -
        var species_visitor = BiologicalSymbolSyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(species_visitor)
        }
        
        return species_visitor.getSyntaxTreeVisitorData() as? [VLEMProxyNode]
    }
    
    static func extractGeneExpressionControlTransferFunctionList(root:SyntaxTreeComposite) -> [VLEMGeneExpressionControlTransferFunctionProxy]? {
        
        // Get type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }

        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            // Build the transfer function tree visitor -
            var gene_expression_control_transfer_function_visitor = GeneExpressionControlFunctionSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(gene_expression_control_transfer_function_visitor)
            }

            return gene_expression_control_transfer_function_visitor.getSyntaxTreeVisitorData() as? [VLEMGeneExpressionControlTransferFunctionProxy]
        }
        
        return nil
    }
    
    static func extractGeneExpressionControlParameterList(root:SyntaxTreeComposite) -> [VLEMGeneExpressionControlParameterProxy]? {
        
        // Get the type dictionary -
        var type_dictionary_visitor = BiologicalTypeDictionarySyntaxTreeVisitor()
        for child_node in root.children_array {
            child_node.accept(type_dictionary_visitor)
        }
        
        // type dictionary -
        if var _type_dictionary:Dictionary<String,SyntaxTreeComponent> = type_dictionary_visitor.getSyntaxTreeVisitorData() as? Dictionary<String,SyntaxTreeComponent> {
            
            var gene_expression_control_parameter_visitor = GeneExpressionControlParameterSyntaxTreeVisitor(typeDictionary: _type_dictionary)
            for child_node in root.children_array {
                child_node.accept(gene_expression_control_parameter_visitor)
            }
            
            return gene_expression_control_parameter_visitor.getSyntaxTreeVisitorData() as? [VLEMGeneExpressionControlParameterProxy]
        }
        
        return nil
    }

    
    // build function header information -
    static func buildCopyrightHeader(functionName:String, functionDescription:String) -> String {
        
        // declarations -
        var buffer = ""
        
        // Get the date -
        let flags: NSCalendarUnit = NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear
        let date = NSDate()
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        let year_string = components.year
        let day_string = components.day
        let month_string = components.month
        let user_name = NSUserName()
        
        buffer+="# ------------------------------------------------------------------------------------- #\n"
        buffer+="# Copyright (c) \(year_string) Varnerlab,\n"
        buffer+="# School of Chemical and Biomolecular Engineering,\n"
        buffer+="# Cornell University, Ithaca NY 14853 USA.\n"
        buffer+="#\n"
        buffer+="# Permission is hereby granted, free of charge, to any person obtaining a copy\n"
        buffer+="# of this software and associated documentation files (the \"Software\"), to deal\n"
        buffer+="# in the Software without restriction, including without limitation the rights\n"
        buffer+="# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"
        buffer+="# copies of the Software, and to permit persons to whom the Software is\n"
        buffer+="# furnished to do so, subject to the following conditions:\n"
        buffer+="# The above copyright notice and this permission notice shall be included in\n"
        buffer+="# all copies or substantial portions of the Software.\n"
        buffer+="#\n"
        buffer+="# THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"
        buffer+="# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"
        buffer+="# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"
        buffer+="# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"
        buffer+="# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"
        buffer+="# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"
        buffer+="# THE SOFTWARE.\n"
        buffer+="#\n"
        buffer+="# \(functionName)\n"
        buffer+="# \(functionDescription)\n"
        buffer+="#\n"
        buffer+="# Generated on: \(month_string)/\(day_string)/\(year_string)\n"
        buffer+="# Generated by: \(user_name)\n"
        
        // if we have a input URL, then write down the file name -
        if let local_input_file_url = JuliaLanguageStrategyLibrary.my_input_url {
            
            // get the file name -
            if let local_file_name = local_input_file_url.lastPathComponent {
                
                buffer+="# Source file: \(local_file_name)\n"
            }
        }
        
        buffer+="# ------------------------------------------------------------------------------------- #\n"
        
        // return the buffer back to caller -
        return buffer
    }
    
}

class JuliaKineticsFileStrategy:CodeGenerationStrategy {
    
    func execute(node:SyntaxTreeComponent) -> String {
        
        // declarations -
        var buffer = ""
        var model_root = node as! SyntaxTreeComposite
        
        // ok, we need to create a function -
        // get the copyright header information -
        var header_information = JuliaLanguageStrategyLibrary.buildCopyrightHeader("Kinetics.jl",
            functionDescription: "Encodes the metabolic and gene expression kinetics.\n# Called by Balances.jl")
        
        buffer+="\(header_information)"
        buffer+="function Kinetics(t,x,DF)\n"
        buffer+="\n"
        
        // initialize the rate vectors -
        buffer+="\t# Initialize empty *_rate_vectors - \n"
        buffer+="\tgene_expression_rate_vector = Float64[]\n"
        buffer+="\tbasal_gene_expression_rate_vector = Float64[]\n"
        buffer+="\tmetabolic_rate_vector = Float64[]\n"
        buffer+="\ttranslation_rate_vector = Float64[]\n"
        buffer+="\tmRNA_degradation_rate_vector = Float64[]\n"
        buffer+="\tprotein_degradation_rate_vector = Float64[]\n"
        buffer+="\tsystem_transfer_rate_vector = Float64[]\n"
        buffer+="\n"
        
        buffer+="\t# Alias state vector - \n"
        if var species_list = JuliaLanguageStrategyLibrary.extractSpeciesList(model_root) where ((species_list as? [VLEMSpeciesProxy]) != nil) {
            
            var counter = 1
            for proxy_object in species_list {
                
                // Get the default value -
                let default_value = (proxy_object as! VLEMSpeciesProxy).default_value
                let state_symbol = (proxy_object as! VLEMSpeciesProxy).state_symbol_string!
                
                buffer+="\t"
                buffer+=state_symbol
                buffer+="\t=\t"
                buffer+="x[\(counter)]\n"
                
                // update the counter -
                counter++
            }
        }
        
        // Get the parameter vectors -
        buffer+="\n"
        buffer+="\t# Get the parameter vectors from DF - \n"
        buffer+="\tgene_expression_parameter_vector = DF[\"GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR\"]\n"
        buffer+="\tmetabolic_parameter_vector = DF[\"METABOLIC_KINETIC_PARAMETER_VECTOR\"]\n"
        
        buffer+="\n"
        buffer+="\t# Regulated gene expression rate vector - \n"
        buffer+="\tfill!(gene_expression_rate_vector,0.0)\n"
        if var expression_kinetics_list = JuliaLanguageStrategyLibrary.extractGeneExpressionKineticsList(model_root) {
            
            for proxy_object in expression_kinetics_list {
            
                if var _proxy_node = proxy_object as? VLEMGeneExpressionKineticsFunctionProxy {
                    
                    // Get the data in the proxy -
                    let parameter_index = _proxy_node.parameter_index
                    let gene_symbol = _proxy_node.gene_symbol
                    
                    // write the buffer entry -
                    buffer+="\tpush!(gene_expression_rate_vector,gene_expression_parameter_vector[\(parameter_index)]*\(gene_symbol))\n"
                }
            }
        }
        
        buffer+="\n"
        buffer+="\t# Basal gene expression rate vector - \n"
        buffer+="\tfill!(basal_gene_expression_rate_vector,0.0)\n"
        if var basal_expression_kinetics_list = JuliaLanguageStrategyLibrary.dispatchGenericTreeVisitorOnTreeWithTypeDictionary(model_root, visitorClassName: "BasalGeneExpressionKineticsFunctionSyntaxTreeVisitor"),
        let _basal_expression_kinetics_list = basal_expression_kinetics_list as? [VLEMProxyNode] {
            
            for proxy_object in _basal_expression_kinetics_list {
                
                if var _proxy_node = proxy_object as? VLEMGeneExpressionKineticsFunctionProxy {
                    
                    // Get the data in the proxy -
                    let parameter_index = _proxy_node.parameter_index
                    let gene_symbol = _proxy_node.gene_symbol
                    
                    // write the buffer entry -
                    buffer+="\tpush!(basal_gene_expression_rate_vector,gene_expression_parameter_vector[\(parameter_index)]*\(gene_symbol))\n"
                }
            }
        }

        buffer+="\n"
        buffer+="\t# Define the translation rate vector - \n"
        buffer+="\tfill!(translation_rate_vector,0.0)\n"
        if var translation_kinetics_list = JuliaLanguageStrategyLibrary.extractProteinTranslationKineticsList(model_root){
            
            for proxy_object in translation_kinetics_list {
             
                if let _proxy_node = proxy_object as? VLEMProteinTranslationKineticsFunctionProxy {
                    
                    // Get the data in the proxy -
                    let parameter_index = _proxy_node.parameter_index
                    let mrna_symbol = _proxy_node.proxy_symbol
                    
                    // write the buffer entry -
                    buffer+="\tpush!(translation_rate_vector,gene_expression_parameter_vector[\(parameter_index)]*\(mrna_symbol))\n"
                }
            }
        }
        
        buffer+="\n"
        buffer+="\t# Define the mRNA degradation rate vector - \n"
        buffer+="\tfill!(mRNA_degradation_rate_vector,0.0)\n"
        if let mrna_degradation_kinetics_array = JuliaLanguageStrategyLibrary.extractMessengerRNADegradationKineticsList(model_root) {
            
            for proxy_object in mrna_degradation_kinetics_array {
                
                if let _proxy_node = proxy_object as? VLEMMessengerRNADegradationKineticsFunctionProxy {
                    
                    // Get the data in the proxy -
                    let parameter_index = _proxy_node.parameter_index
                    let mrna_symbol = _proxy_node.proxy_symbol
                    
                    // write the buffer entry -
                    buffer+="\tpush!(mRNA_degradation_rate_vector,gene_expression_parameter_vector[\(parameter_index)]*\(mrna_symbol))\n"
                }
            }
        }

        buffer+="\n"
        buffer+="\t# Define the protein degradation rate vector - \n"
        buffer+="\tfill!(protein_degradation_rate_vector,0.0)\n"
        if let protein_degradation_kinetics_array = JuliaLanguageStrategyLibrary.extractProteinDegradationKineticsList(model_root) {
            
            for proxy_object in protein_degradation_kinetics_array {
                
                if let _proxy_node = proxy_object as? VLEMProteinDegradationKineticsFunctionProxy {
                    
                    // Get the data in the proxy -
                    let parameter_index = _proxy_node.parameter_index
                    let protein_symbol = _proxy_node.proxy_symbol
                    
                    // write the buffer entry -
                    buffer+="\tpush!(protein_degradation_rate_vector,gene_expression_parameter_vector[\(parameter_index)]*\(protein_symbol))\n"
                }
            }
        }

        buffer+="\n"
        buffer+="\t# Define the metabolic rate vector - \n"
        buffer+="\tfill!(metabolic_rate_vector,0.0)\n"
        
        buffer+="\n"
        buffer+="\t# Define the system transfer rate vector - \n"
        buffer+="\tfill!(system_transfer_rate_vector,0.0)\n"
        
        buffer+="\n"
        buffer+="\t# Return the rate vectors to the caller in a dictionary - \n"
        buffer+="\t# - DO NOT EDIT BELOW THIS LINE ------------------------------ \n"
        buffer+="\tkinetics_dictionary = Dict()\n"
        buffer+="\tkinetics_dictionary[\"gene_expression_rate_vector\"] = gene_expression_rate_vector\n"
        buffer+="\tkinetics_dictionary[\"translation_rate_vector\"] = translation_rate_vector\n"
        buffer+="\tkinetics_dictionary[\"mRNA_degradation_rate_vector\"] = mRNA_degradation_rate_vector\n"
        buffer+="\tkinetics_dictionary[\"protein_degradation_rate_vector\"] = protein_degradation_rate_vector\n"
        buffer+="\tkinetics_dictionary[\"metabolic_rate_vector\"] = metabolic_rate_vector\n"
        buffer+="\tkinetics_dictionary[\"system_transfer_rate_vector\"] = system_transfer_rate_vector\n"
        buffer+="\t# - DO NOT EDIT ABOVE THIS LINE ------------------------------ \n"
        buffer+="\treturn kinetics_dictionary\n"
    
        buffer+="end"
        
        // return -
        return buffer
    }
}

class JuliaControlFileStrategy:CodeGenerationStrategy {
 
    func execute(node:SyntaxTreeComponent) -> String {
        
        // declarations -
        var buffer:String = ""
        
        // get the copyright header information -
        var header_information = JuliaLanguageStrategyLibrary.buildCopyrightHeader("Control.jl",
            functionDescription: "Calculates the metabolic and gene expression control vector. Called by Balances.jl.")
        
        buffer+="\(header_information)"
        buffer+="function Control(t,x,rate_vector,metabolic_rate_vector,DF)\n"
        buffer+="\n"
        buffer+="\t# Initialize control_vector - \n"
        buffer+="\tcontrol_vector_gene_expression = Float64[];\n"
        buffer+="\tcontrol_vector_metabolism = Float64[];\n"
        buffer+="\n"
        buffer+="\t# Get the parameter_vector - \n"
        buffer+="\tg = DF[\"GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR\"];\n"
        buffer+="\tm = DF[\"METABOLIC_CONTROL_PARAMETER_VECTOR\"];\n"
        buffer+="\n"
        buffer+="\t# Alias the state vector - \n"
        
        // Build species list -
        var model_root = node as! SyntaxTreeComposite
        if var species_list = JuliaLanguageStrategyLibrary.extractSpeciesList(model_root) where ((species_list as? [VLEMSpeciesProxy]) != nil) {
            
            var counter = 1
            for proxy_object in species_list {
                
                // Get the default value -
                let default_value = (proxy_object as! VLEMSpeciesProxy).default_value
                let state_symbol = (proxy_object as! VLEMSpeciesProxy).state_symbol_string!
                
                buffer+="\t"
                buffer+=state_symbol
                buffer+="\t=\t"
                buffer+="x[\(counter)];\n"
                
                // update the counter -
                counter++
            }
        }
        
        buffer+="\n"
        buffer+="\t# Formulate the gene expression control vector - \n"
        var counter = 0
        if var gene_expression_control_model = JuliaLanguageStrategyLibrary.extractGeneExpressionControlModel(model_root){
            
            if var species_list = JuliaLanguageStrategyLibrary.extractSpeciesList(model_root) where ((species_list as? [VLEMSpeciesProxy]) != nil) {
                
                for proxy_object in species_list {
                    
                    let target_lexeme = (proxy_object as! VLEMSpeciesProxy).state_symbol_string!
                    if let control_tree_array = gene_expression_control_model[target_lexeme] {
                        
                        buffer+="\t# Control structure for \(target_lexeme)\n"
                        buffer+="\tf_vector = Float64[]\n"
                        
                        for proxy:VLEMControlRelationshipProxy in control_tree_array {
                            
                            if (proxy.token_type == TokenType.INDUCE || proxy.token_type == TokenType.INDUCES) {
                                
                                if let _effector_lexeme_array = proxy.effector_lexeme_array {
                                    
                                    for _effector_lexeme in _effector_lexeme_array {
                                        buffer+="\tpush!(f_vector,(g[\(++counter)]*(\(_effector_lexeme))^g[\(++counter)])/(1 + g[\(--counter)]*(\(_effector_lexeme))^g[\(++counter)]));\n"
                                    }
                                }
                            }
                            else if (proxy.token_type == TokenType.REPRESS || proxy.token_type == TokenType.REPRESSES){
                             
                                if let _effector_lexeme_array = proxy.effector_lexeme_array {
                                    
                                    for _effector_lexeme in _effector_lexeme_array {
                                        buffer+="\tpush!(f_vector,1.0 - (g[\(++counter)]*(\(_effector_lexeme))^g[\(++counter)])/(1 + g[\(--counter)]*(\(_effector_lexeme))^g[\(++counter)]));\n"
                                    }
                                }
                            }
                        }
                        
                        buffer+="\tpush!(control_vector_gene_expression,mean(f_vector));\n"
                        buffer+="\n"
                    }
                }
            }
        }
        
        //buffer+="\n"
        //buffer+="\t# Formulate the metabolic control vector - \n"
        //buffer+="\n"
        
        buffer+="\t# Return the gene expression and metabolic control vectors - \n"
        buffer+="\treturn (control_vector_gene_expression, control_vector_metabolism)\n"
        buffer+="end"
        
        // return -
        return buffer
    }
}

class JuliaBalanceEquationsFileStrategy:CodeGenerationStrategy {
    
    func execute(node:SyntaxTreeComponent) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="# Include statements - \n"
        buffer+="include(\"Kinetics.jl\")\n"
        buffer+="include(\"Control.jl\")\n"
        buffer+="\n"
        
        // get the copyright header information -
        var header_information = JuliaLanguageStrategyLibrary.buildCopyrightHeader("Balances.jl",
            functionDescription: "Encodes the material balance equations for the metabolic model.\n# Called by SolveBalanceEquations.jl")
        
        buffer+="\(header_information)"
        buffer+="function Balances(t,x,dxdt_vector,DF)\n"
        buffer+="\n"
        
        buffer+="\t# Define the rate_vector - \n"
        buffer+="\tkinetics_dictionary = Kinetics(t,x,DF);\n"
        buffer+="\tgene_expression_rate_vector = kinetics_dictionary[\"gene_expression_rate_vector\"];\n"
        buffer+="\ttranslation_rate_vector = kinetics_dictionary[\"translation_rate_vector\"];\n"
        buffer+="\tmetabolic_rate_vector = kinetics_dictionary[\"metabolic_rate_vector\"];\n"
        buffer+="\tmRNA_degradation_rate_vector = kinetics_dictionary[\"mRNA_degradation_rate_vector\"];\n"
        buffer+="\tprotein_degradation_rate_vector = kinetics_dictionary[\"protein_degradation_rate_vector\"];\n"
        
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
        
        // Get the model_root -
        var model_root = node as! SyntaxTreeComposite
        if var species_list = JuliaLanguageStrategyLibrary.extractSpeciesList(model_root), var _target_list = JuliaLanguageStrategyLibrary.extractTargetList(model_root) where (species_list as? [VLEMSpeciesProxy]) != nil  {
        
            buffer+="\t# Define the dxdt_vector - \n"
            buffer+="\t# Gene balances - \n"
            // process the genes -
            var gene_counter = 1
            for proxy_object in species_list {
                
                if ((proxy_object as! VLEMSpeciesProxy).token_type == TokenType.DNA) {
                    
                    let state_symbol = (proxy_object as! VLEMSpeciesProxy).state_symbol_string
                    buffer+="\tdxdt_vector[\(gene_counter)] = 0.0;\t#\t\(gene_counter)\t\(state_symbol!)\n"
                    
                    // update gene counter -
                    gene_counter++
                }
            }
            
            buffer+="\n"
            buffer+="\t# mRNA balances - \n"
            
            // process the mRNA -
            var mRNA_counter = gene_counter
            var rate_counter = 1
            for proxy_object in species_list {
                
                if ((proxy_object as! VLEMSpeciesProxy).token_type == TokenType.MESSENGER_RNA){
                    
                    let state_symbol = (proxy_object as! VLEMSpeciesProxy).state_symbol_string!
                    
                    // ok, is this proxy in the target?
                    if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(_target_list, node: proxy_object) == true){
                        
                        
                        buffer+="\tdxdt_vector[\(mRNA_counter)] = gene_expression_rate_vector[\(rate_counter)] - mRNA_degradation_rate_vector[\(rate_counter)];\t#\t\(mRNA_counter)\t\(state_symbol)\n"
                        
                        // update the rate counter -
                        rate_counter++
                    }
                    else {
                        buffer+="\tdxdt_vector[\(mRNA_counter)] = 0.0;\t#\t\(mRNA_counter)\t\(state_symbol)\n"
                    }
                    
                    // update the counter -
                    mRNA_counter++
                }
            }
            
            
            buffer+="\n"
            buffer+="\t# Protein balances - \n"
        
            // process the proteins -
            var protein_counter = mRNA_counter
            rate_counter = 1
            for proxy_object in species_list {
                
                if ((proxy_object as! VLEMSpeciesProxy).token_type == TokenType.PROTEIN){
                    
                    let state_symbol = (proxy_object as! VLEMSpeciesProxy).state_symbol_string!
                    
                    // ok, is this proxy in the target?
                    if (VLEMAbstractSyntaxTreeVisitorLibrary.arrayContainsProxyNode(_target_list, node: proxy_object) == true){
                        
                        buffer+="\tdxdt_vector[\(protein_counter)] = translation_rate_vector[\(rate_counter)] - protein_degradation_rate_vector[\(rate_counter)];\t#\t\(protein_counter)\t\(state_symbol)\n"
                        
                        // update the rate counter -
                        rate_counter++
                    }
                    else {
                        buffer+="\tdxdt_vector[\(protein_counter)] = 0.0;\t#\t\(protein_counter)\t\(state_symbol)\n"
                    }
                    
                    // update the counter -
                    protein_counter++
                }
            }
        }

        buffer+="\treturn dxdt_vector;\n"
        buffer+="end"
        
        // return -
        return buffer
    }
}

class JuliaProjectIncludeFileStrategy:CodeGenerationStrategy {
    
    func execute(node:SyntaxTreeComponent) -> String {
        
        // declarations -
        var buffer:String = ""
        
        // get the copyright header information -
        var header_information = JuliaLanguageStrategyLibrary.buildCopyrightHeader("Project.jl",
            functionDescription: "Include statements for all model files.")
        
        buffer+="\(header_information)"
        buffer+="include(\"DataFile.jl\")\n"
        buffer+="include(\"Balances.jl\")\n"
        buffer+="include(\"Control.jl\")\n"
        buffer+="include(\"Kinetics.jl\")\n"
        buffer+="include(\"SolveBalanceEquations.jl\")\n"
        
        // return -
        return buffer
    }
}

class JuliaSolveBalanceEquationsFileStrategy:CodeGenerationStrategy {
    
    func execute(root:SyntaxTreeComponent) -> String {
        
        // declarations -
        var buffer:String = ""
        
        buffer+="# Include statements - \n"
        buffer+="include(\"DataFile.jl\")\n"
        buffer+="include(\"Balances.jl\")\n"
        buffer+="using Sundials\n"
        buffer+="\n"
        
        // get the copyright header information -
        var header_information = JuliaLanguageStrategyLibrary.buildCopyrightHeader("SolveBalanceEquations.jl",
            functionDescription: "Solve the balance equations using CVODE from the SUNDIALS package.")
        
        buffer+="\(header_information)"
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

class JuliaDataFileFileStrategy:CodeGenerationStrategy {
    
    func execute(root:SyntaxTreeComponent) -> String {
        
        // declarations -
        var buffer:String = ""
        
        // get the copyright header information -
        var header_information = JuliaLanguageStrategyLibrary.buildCopyrightHeader("DataFile.jl",
            functionDescription: "Creates a data dictionary holding initial conditions, and the kinetic/control\n# parameters for the model. Called by SolveBalanceEquations.jl")
        
        buffer+="\(header_information)"
        buffer+="function DataFile(TSTART,TSTOP,Ts,INDEX)\n"
        buffer+="\n"
        
        // Initialize -
        buffer+="\t# Set the initial condition - \n"
        buffer+="\tIC_ARRAY = Float64[]\n"
        
        // Build IC list -
        var model_root = root as! SyntaxTreeComposite
        if var species_list = JuliaLanguageStrategyLibrary.extractSpeciesList(model_root) {
            
            var counter = 1
            for proxy_object in species_list {
                
                if let _proxy_object = proxy_object as? VLEMSpeciesProxy {
                 
                    // Get the default value -
                    let default_value = _proxy_object.default_value
                    let state_symbol = _proxy_object.state_symbol_string
                    
                    // write the record -
                    buffer+="\tpush!(IC_ARRAY,\(default_value!))\t"
                    buffer+="#\t\(counter)\t\(state_symbol!)\n"
                    
                    // update the counter -
                    counter++
                }
            }
        }
        
        // Build the list of gene expression kinetic parameters -
        buffer+="\n"
        buffer+="\t# Setup the gene expression kinetic parameter vector - \n"
        buffer+="\tGENE_EXPRESSION_KINETIC_PARAMETER_VECTOR = Float64[]\n"
        if var gene_expression_rate_list = JuliaLanguageStrategyLibrary.extractGeneExpressionRateList(model_root) {
            
            var counter = 1
            for proxy_object in gene_expression_rate_list {
            
                // get default value -
                let default_value = proxy_object.default_value
                let rate_description = proxy_object.rate_description!
                
                // write the record -
                buffer+="\tpush!(GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR,\(default_value))\t"
                buffer+="#\t\(counter)\t\(rate_description)\n"

                // update the counter -
                counter++
            }
        }
        else {
            buffer+="\t# No gene expression processes appear in the model.\n"
        }
        
        // Build the metabolic kinetic parameter vector -
        buffer+="\n"
        buffer+="\t# Setup the metabolic kinetic parameter vector - \n"
        buffer+="\tMETABOLIC_KINETIC_PARAMETER_VECTOR = Float64[]\n"
        buffer+="\n"
        
        // Setup the gene expression control parameter vector -
        buffer+="\n"
        buffer+="\t# Setup the gene expression control parameter vector - \n"
        buffer+="\tGENE_EXPRESSION_CONTROL_PARAMETER_VECTOR = Float64[]\n"
        if var gene_expression_control_parameters = JuliaLanguageStrategyLibrary.extractGeneExpressionControlParameterList(model_root){
            
            var counter = 1
            for proxy_object in gene_expression_control_parameters {
                
                // get default value -
                let default_value = proxy_object.default_value
                
                // write the record -
                buffer+="\tpush!(GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR,\(default_value))\t"
                
                if let _parameter_description = proxy_object.proxy_description {
                    buffer+="#\t\(counter)\t \(_parameter_description)\n"
                }
                else {
                    buffer+="#\t\(counter)\t gene expression control parameter \n"
                }
                
                // update the counter -
                counter++
            }
            
        }
        else {
            buffer+="\t# No gene expression control terms appear in the model.\n"
        }
        
        // Setup the metabolic control parameter vector -
        buffer+="\n"
        buffer+="\t# Setup the metabolic control parameter vector - \n"
        buffer+="\tMETABOLIC_CONTROL_PARAMETER_VECTOR = Float64[]\n"
        buffer+="\n"
        
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




