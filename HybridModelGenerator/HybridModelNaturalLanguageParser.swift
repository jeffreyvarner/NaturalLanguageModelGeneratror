//
//  HybridModelNaturalLanguageParser.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/22/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum ActionVerb:String {
    
    case INDUCES = "induces"
    case REPRESSES = "represses"
    case TRANSLATES = "translates"
    case TRANSCRIBES = "transcribes"
    case EXPRESSION = "EXPRESSION"
    case TRANSCRIPTION = "TRANSCRIPTION"
    case PARAMETERS = "PARAMETERS"
    case PARAMETER = "PARAMETER"
    case CATALYZES = "CATALYZES"
    case ACTIVATES = "ACTIVATES"
    case ACTIVATE = "ACTIVATE"
    case INACTIVATES = "INACTIVATES"
    case INACTIVATE = "INACTIVATE"
    case INHIBITS = "INHIBITS"
    case INHIBIT = "INHIBIT"
    case BINDS = "BINDS"
    case BIND = "BIND"
    case SYSTEM = "SYSTEM"
    
    
    // allows iteration -
    static let allVerbs = [INDUCES,REPRESSES,TRANSLATES,TRANSCRIBES,TRANSCRIPTION,EXPRESSION,PARAMETERS,PARAMETER,CATALYZES,ACTIVATES,ACTIVATE,INACTIVATES,INACTIVATE,INHIBITS,INHIBIT,SYSTEM]
}

enum RoleDescriptor:String {
    
    case CONSTANT = "constant"
    case DYNAMIC = "dynamic"
}

enum TypeDescriptor:String {
    
    case GENE = "GENE"
    case mRNA = "mRNA"
    case PROTIEN = "PROTIEN"
    case METABOLITE = "METABOLITE"
    case OTHER = "OTHER"
}

// Used to hold 'control' tables -
struct Matrix {
    
    let rows: Int, columns: Int
    var grid: [Int]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(count: rows * columns, repeatedValue: 0)
    }
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    func isColumnAllZeros(column:Int) -> Bool {
        
        // declarations -
        var return_flag = true
        
        for var row_index = 0;row_index<rows;row_index++ {
            
            let value = grid[(row_index * columns) + column]
            if (value != 0)
            {
                return_flag = false
                break
            }
        }
        
        return return_flag
    }
    
    subscript(row: Int, column: Int) -> Int {
        
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

struct StoichiometricMatrix {
    
    let rows: Int, columns: Int
    var grid: [Double]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(count: rows * columns, repeatedValue: 0.0)
    }
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Double {
        
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}


class HybridModelNaturalLanguageParser: NSObject {
    
    // declarations -
    private var myModelInputURL:NSURL
    
    init(_inputURL inputURL:NSURL){
        self.myModelInputURL = inputURL
    }
    
    // main method
    func parse() -> HybridModelContext {
        
        // declarations -
        var model_context = HybridModelContext()
        var local_model_commands = [String]()
        
        // load raw text -
        let raw_model_buffer = String(contentsOfURL: self.myModelInputURL, encoding:NSUTF8StringEncoding, error: nil)
        
        // Ok, we need to ignore comments, and split the string -
        let component_array = raw_model_buffer?.componentsSeparatedByString("\n");
        
        // iterate through the lines, and put into an array. Get rid of empty lines, and lines that
        // start with //
        for raw_text_line in component_array! {
            
            if (raw_text_line.isEmpty == false &&
                containsString(raw_text_line, test_string: "//") == false){
                    
                    local_model_commands.append(raw_text_line)
            }
        }

        // Ok, now that we have our list of statements, we need to iterate through and look for action words -
        var mRNA_array = extractListOfmRNAsFromModelStatementArray(_listOfStatements:local_model_commands)
        var protein_array = extractListOfProteinsFromModelStatementArray(_listOfStatements: local_model_commands)
        var infrastructure_and_parameter_array = extractListOfInfrastructureSymbolsFromModelStatementArray(_listOfStatements: local_model_commands)
        
        // Extract the metabolite symbol and reaction list -
        let metabolism_return = extractListOfMetabolitesFromModelStatementArray(_listOfStatements: local_model_commands)
        let metabolite_array = metabolism_return.symbols
        let metabolic_reaction_array = metabolism_return.reactions
        model_context.metabolic_reaction_array = metabolic_reaction_array
        
        // Formulate the stoichiometric matrix -
        let stochiometric_matrix = constructStoichiometricMatrixForMetabolitesInReactionArray(metabolic_reaction_array,listOfMetabolites: metabolite_array)
        model_context.metabolic_stoichiometric_matrix = stochiometric_matrix
        
        // Extract gene expression control table -
        var (gene_expression_control_table, effector_array) = extractGeneExpressionControlTableFromModelStatementArray(_listOfStatements: local_model_commands,listOfOutputSymbols: mRNA_array)
        
        // build the state array -
        var state_array = mRNA_array+protein_array+infrastructure_and_parameter_array+effector_array+metabolite_array
        for state_symbol in state_array {
            model_context.addStateSymbolsToModelContext(state_symbol)
        }
        
        // Grab the *unique* state array -
        let unique_state_symbol_array = model_context.state_symbol_array
        
        // Populate the model context -
        model_context.gene_expression_control_matrix = gene_expression_control_table
        model_context.gene_expression_effector_array = effector_array
        model_context.gene_expression_output_array = mRNA_array
        model_context.translation_output_array = protein_array
        
        // Ok, what are the *roles* of these symbols, and their default values?
        let symbol_role_dictionary = extractSymbolRoleDictionaryFromModelStatementArray(_listOfStatements: local_model_commands, listOfSymbols: unique_state_symbol_array)
        let default_symbol_value_dictionary = extractDefaultParameterValuesFromModelStatementArray(_listOfStatements: local_model_commands, listOfSymbols: unique_state_symbol_array)
        
        // Create the state model dictionary -
        var state_model_dictionary = Dictionary<String,HybridStateModel>()
        for (symbol,value) in default_symbol_value_dictionary {
            
            // Create a symbol object -
            var symbol_object = HybridStateModel(symbol: symbol)
            
            // Set the default value -
            symbol_object.default_value = value
            
            // put the state_model in the state_model_dictionary -
            state_model_dictionary[symbol] = symbol_object
        }
        
        // ok, set the role flag on the state model -
        for (state_symbol,state_model) in state_model_dictionary {
            
            // Lookup the role -
            let role_flag = symbol_role_dictionary[state_symbol]
            
            // Get the state_model -
            state_model.state_role = role_flag
        }
        
        // Ok, try to estimate the *type* of species that we have, is it a mRNA, protein or Metabolite?
        let symbol_type_dictionary = extractSymbolTypeFromModelStatementArray(_listOfStatements: local_model_commands, listOfSymbols: unique_state_symbol_array)
        for (state_symbol,state_model) in state_model_dictionary {
            
            // Lookup the role -
            let type_flag = symbol_type_dictionary[state_symbol]
            
            // Get the state_model -
            state_model.state_type = type_flag
        }
        
        // Ok, try to estimate the precursors for each
        let precursor_symbol_dictionary = extractPrecursorSymbolsFromModelStatementArray(_listOfStatements: local_model_commands, listOfSymbols: unique_state_symbol_array)
        for (state_symbol,state_model) in state_model_dictionary {
            
            // Lookup the role -
            let precursor_array = precursor_symbol_dictionary[state_symbol]
            
            // Get the state_model -
            state_model.state_precursor_symbol_array = precursor_array
        }
        
        // ok, let's extract the metabolic control table from the list of statements -
        let metabolic_control_results = extractMetabolicControlTableFromModelStatementArray(_listOfStatements:local_model_commands)
        if let local_metabolic_control_table = metabolic_control_results.control_table {
            
            let effector_array = metabolic_control_results.actors
            let target_array = metabolic_control_results.targets
            
            // update the model context -
            model_context.metabolic_control_effector_symbol_array = effector_array
            model_context.metabolic_control_target_symbol_array = target_array
            model_context.metabolic_control_table = local_metabolic_control_table
        }
        
        // set the state model -
        model_context.state_model_dictionary = state_model_dictionary
        
        // Process any directives -
        processPragmaDirectivesFromModelStatementArray(_listOfStatements:local_model_commands,modelContext:&model_context)
        
        // return the context -
        return model_context
    }
    
    
    // MARK: Process the directives
    private func processPragmaDirectivesFromModelStatementArray(_listOfStatements listOfStatements:[String],inout modelContext:HybridModelContext) -> Void {
        
        // ok, extract the #pragma directives -
        var local_directive_array = [String]()
        
        // Go through the sentences, extract #pragma
        for model_sentence in listOfStatements {
            
            if (containsString(model_sentence, test_string:"#pragma") == true) {
                
                local_directive_array.append(model_sentence)
            }
        }
        
        // ok, we have keyword = value structure -
        for pragma_statement in local_directive_array {
            
            // split around =
            let split_around_equal_array = pragma_statement.componentsSeparatedByString("=")
            let keyword = split_around_equal_array.first!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let value = split_around_equal_array.last!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
            // ok, which keyword do we have?
            if (keyword == "#pragma integration_rule" && value == "mean"){
                modelContext.integration_rule = IntegrationRuleType.MEAN
            }
        }
    }
    
    // MARK: Metabolic * methods
    private func extractMetabolicControlTableFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> (control_table:Matrix?,actors:[String], targets:[String]) {
        
        // ok, we need to extract the statements associated with metabolic regulation -
        var metabolic_regulation_statements = [String]()
        var metabolic_effector_array = [String]()
        var metabolic_target_array = [String]()
        var metabolic_control_matrix:Matrix?
        
        // create wrapper struct -
        struct MetabolicRegulationWrapper {
            
            let effect_symbol_array:[String]
            let target_symbol_array:[String]
            let action_verb:ActionVerb
            
            init (effectors:[String],targets:[String], action:ActionVerb)
            {
                effect_symbol_array = effectors
                target_symbol_array = targets
                action_verb = action
            }
            
            
            func regulationTypeForTargetEffectorPair(target:String,effector:String) -> Int {
                
                // default relationship is 0
                var relationship_flag = 0
                
                if (contains(effect_symbol_array, effector) == true &&
                    contains(target_symbol_array, target) == true){
                        
                    if (action_verb == ActionVerb.ACTIVATE ||
                        action_verb == ActionVerb.ACTIVATES){
                        
                        // We have a +1 relationship -
                        relationship_flag = 1
                    }
                    else {
                        relationship_flag = -1
                    }
                }
                
                // return -
                return relationship_flag
            }
        }
        
        // utility functions -
        func extractActionTypeFromModelStatement(statementText:String) -> ActionVerb {
        
            // declarations -
            var action_verb = ActionVerb.ACTIVATE
            
            for verb_symbol in ActionVerb.allVerbs {
            
                // does statement contain one of our verbs?
                if (containsString(statementText, test_string: verb_symbol.rawValue) == true){
                
                    // Grab the verb -
                    action_verb = verb_symbol
                    
                    // break out of the loop -
                    break;
                }
            }
            
            
            // return -
            return action_verb
        }
        
        func addSymbolToList(inout list:[String],symbol:String) -> Void {
        
            if (contains(list, symbol) == false){
                list.append(symbol)
            }
        }
        
        
        func parseCompoundStatement(compundStatement:String)-> [String] {
            
            // Declarations -
            var list_of_symbols = [String]()
            
            // Do we have a compound statement in the target?
            if (containsString(compundStatement, test_string: "(") == true){
                
                // split the compound target_fragment =
                let tmp_comma_sep_list = compundStatement.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                let target_symbol_array = tmp_comma_sep_list.componentsSeparatedByString(",")
                
                for symbol in target_symbol_array {
                    
                    if (contains(list_of_symbols, symbol) == false){
                        list_of_symbols.append(symbol)
                    }
                }
            }
            else {
                
                let tmp_fragment = compundStatement.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                // ok, target fragment is *not* a compound list -
                if (contains(list_of_symbols, tmp_fragment) == false){
                    list_of_symbols.append(tmp_fragment)
                }
            }
            
            // return -
            return list_of_symbols
        }
        
        
        
        // iterate through the listOfStatements and grab those that are associated with metabolic regulation -
        for statement_text in listOfStatements {
         
            // does this statement contain any of the metabolic regulation terms?
            if (containsString(statement_text,test_string:ActionVerb.ACTIVATES.rawValue) == true ||
                containsString(statement_text,test_string:ActionVerb.INHIBITS.rawValue) == true ||
                containsString(statement_text,test_string:ActionVerb.INHIBIT.rawValue) == true ||
                containsString(statement_text,test_string:ActionVerb.INACTIVATES.rawValue) == true ||
                containsString(statement_text,test_string:ActionVerb.INACTIVATE.rawValue) == true ||
                containsString(statement_text,test_string:ActionVerb.ACTIVATE.rawValue) == true){
             
                // ok, we have a statement that contains our "action verb"
                metabolic_regulation_statements.append(statement_text)
            }
        }
        
        // ok, so now let's go through the metabolic_regulation_statements 
        var my_regulatory_wrapper_list = [MetabolicRegulationWrapper]()
        for metabolic_regulation_statement in metabolic_regulation_statements {
            
            // tokenize on white space - the first position is the effector, the last is the target 
            let split_on_whitespace_array = metabolic_regulation_statement.componentsSeparatedByString(" ")
            
            // grab the first -
            if let effector_compound_statement:String = split_on_whitespace_array.first {
            
                if let target_compound_statement:String = split_on_whitespace_array.last {
                 
                    // split -
                    let my_effector_symbol_array = parseCompoundStatement(effector_compound_statement)
                    let my_target_symbol_array = parseCompoundStatement(target_compound_statement)
                    
                    // ok, we have targets, and effectors. However, we don't know *what* type of
                    
                    // of relationship we have ...
                    for effector_symbol in my_effector_symbol_array {
                        addSymbolToList(&metabolic_effector_array, effector_symbol)
                    }
                    
                    for target_symbol in my_target_symbol_array {
                        addSymbolToList(&metabolic_target_array, target_symbol)
                    }
                    
                    // which type of interaction do we have?
                    let action_verb = extractActionTypeFromModelStatement(metabolic_regulation_statement)
                    
                    // build the wrapper -
                    let regulatory_wrapper = MetabolicRegulationWrapper(effectors: my_effector_symbol_array, targets: my_target_symbol_array, action: action_verb)
                    
                    // add to list -
                    my_regulatory_wrapper_list.append(regulatory_wrapper)
                }
            }
        }
        
        // ok, so we have a list of regulatory wrappers, list of targets, and effectors. Create the array -
        metabolic_control_matrix = Matrix(rows: metabolic_effector_array.count, columns: metabolic_target_array.count)
        for metabolic_wrapper in my_regulatory_wrapper_list {
            
            // get the effectors -
            let local_effector_symbol_array = metabolic_wrapper.effect_symbol_array
            for effector_symbol in local_effector_symbol_array {
            
                // what is the index of this effector?
                if let index_of_effector = find(metabolic_effector_array,effector_symbol) {
                 
                    // what is the index of the target -
                    let local_target_symbol_array = metabolic_wrapper.target_symbol_array
                    for local_target_symbol in local_target_symbol_array {
                    
                        if let index_of_target = find(metabolic_target_array,local_target_symbol) {
                            
                            // ok, we have both the effector, and the target, what is the value of the interaction?
                            let value_of_interaction = metabolic_wrapper.regulationTypeForTargetEffectorPair(local_target_symbol, effector: effector_symbol)
                            
                            // Add this to the metabolic array -
                            metabolic_control_matrix![index_of_effector,index_of_target] = value_of_interaction
                        }
                    }
                }
            }
        }
        
        return (metabolic_control_matrix,metabolic_effector_array,metabolic_target_array)
    }
    
    private func constructStoichiometricMatrixForMetabolitesInReactionArray(listOfReactions:[HybridModelReactionModel], listOfMetabolites:[String]) -> StoichiometricMatrix {
    
        // Declarations -
        let number_of_metabolites = listOfMetabolites.count
        let number_of_metabolic_reactions = listOfReactions.count
        var stoichiometric_matrix = StoichiometricMatrix(rows: number_of_metabolites,columns: number_of_metabolic_reactions)
        
        // add values to the array -
        var species_counter = 0
        for metabolic_string in listOfMetabolites {
        
            var reaction_counter = 0
            for reaction_object in listOfReactions {
            
                // is this metabolite a reactant or product of this reaction?
                if (reaction_object.isModelSymbolAProduct(metabolic_string) == true){
                    stoichiometric_matrix[species_counter,reaction_counter] = 1.0
                }
                else if (reaction_object.isModelSymbolASubstrate(metabolic_string) == true){
                    stoichiometric_matrix[species_counter,reaction_counter] = -1.0
                }
                
                
                // update reaction counter -
                reaction_counter++
            }
            
            // update species counter -
            species_counter++
        }
        
        // return -
        return stoichiometric_matrix
    }
    
    // MARK: Extract * methods
    private func extractListOfMetabolitesFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> (symbols:[String],reactions:[HybridModelReactionModel]) {
    
        // Declarations --
        var list_of_symbols = [String]()
        var list_of_reactions = [HybridModelReactionModel]()
        
        
        // utility functions -
        func parseCompoundStatement(compundStatement:String)-> [String] {
            
            // Declarations -
            var list_of_symbols = [String]()
            
            // Do we have a compound statement in the target?
            if (containsString(compundStatement, test_string: "(") == true){
                
                // split the compound target_fragment =
                let tmp_comma_sep_list = compundStatement.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                let target_symbol_array = tmp_comma_sep_list.componentsSeparatedByString(",")
                
                for symbol in target_symbol_array {
                    
                    if (contains(list_of_symbols, symbol) == false){
                        list_of_symbols.append(symbol)
                    }
                }
            }
            else {
                
                let tmp_fragment = compundStatement.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                // ok, target fragment is *not* a compound list -
                if (contains(list_of_symbols, tmp_fragment) == false){
                    list_of_symbols.append(tmp_fragment)
                }
            }
            
            // return -
            return list_of_symbols
        }
        
        
        // ok, we need to look for symbols that are involved with CATALYZE statements -
        var reaction_index = 0
        for statement_text in listOfStatements {
            
            // check to see if this contains a SYSTEM statement -
            if (containsString(statement_text, test_string:ActionVerb.SYSTEM.rawValue) == true){
                
                // ok, we have a SYSTEM line - is this going from or to SYSTEM?
                if (containsString(statement_text,test_string:"transferred from") == true){
                
                    // ok, split along whitespace -
                    let white_space_token_array = cutStatement(statement_text, text_delimiter: " ")
                    
                    // grab the first element -
                    if let local_symbol = white_space_token_array.first {
                        
                        // explode the tuple -
                        let local_symbol_array = parseCompoundStatement(local_symbol)
                        
                        for zero_order_symbol in local_symbol_array {
                                
                            // build reaction model -
                            var model_object = HybridModelReactionModel()
                            model_object.product_symbol_list = [zero_order_symbol]
                            model_object.reactant_symbol_list = [ActionVerb.SYSTEM.rawValue]
                            
                            // set the reaction index -
                            model_object.reaction_index = reaction_index++
                            
                            // add reaction model to list -
                            list_of_reactions.append(model_object)
                        }
                    }
                }
                else if (containsString(statement_text,test_string:"transferred to") == true) {
                    
                    // ok, split along whitespace -
                    let white_space_token_array = cutStatement(statement_text, text_delimiter: " ")
                    
                    // grab the first element -
                    if let local_symbol = white_space_token_array.first {
                        
                        // explode the tuple -
                        let local_symbol_array = parseCompoundStatement(local_symbol)
                        
                        for zero_order_symbol in local_symbol_array {
                            
                            // build reaction model -
                            var model_object = HybridModelReactionModel()
                            model_object.reactant_symbol_list = [zero_order_symbol]
                            model_object.product_symbol_list = [ActionVerb.SYSTEM.rawValue]
                            
                            // set the reaction index -
                            model_object.reaction_index = reaction_index++
                            
                            // add reaction model to list -
                            list_of_reactions.append(model_object)
                        }
                    }
                }
            }
            
            // check, does this statement contain "catalyzes" or catalyze?
            if (containsString(statement_text, test_string: ActionVerb.CATALYZES.rawValue) == true){
            
                // ok! we have a catalyzes statement -
                // cut around -> 
                let arrow_split_fragment_array = statement_text.componentsSeparatedByString("->")
                
                // cut around white space -
                let target_fragment = arrow_split_fragment_array.last?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let source_fragment = arrow_split_fragment_array.first?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ").last
                
                // parse the compound statements --
                let source_symbol_list = parseCompoundStatement(source_fragment!)
                let target_symbol_list = parseCompoundStatement(target_fragment!)
                
                // Add the target symbols to the list of symbols -
                let tmp_array = source_symbol_list+target_symbol_list
                for local_symbol in tmp_array {
                    if (contains(list_of_symbols, local_symbol) == false){
                        list_of_symbols.append(local_symbol)
                    }
                }
                
                // need to get enzyme symbol -
                let enzyme_symbol = arrow_split_fragment_array.first?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ").first
                
                // Build reaction model -
                var local_reaction_model = HybridModelReactionModel()
                local_reaction_model.reactant_symbol_list = source_symbol_list
                local_reaction_model.product_symbol_list = target_symbol_list
                local_reaction_model.catalyst_symbol = enzyme_symbol
                
                // set the reaction index -
                local_reaction_model.reaction_index = reaction_index++
                
                // add reaction model to list -
                list_of_reactions.append(local_reaction_model)
            }
        }
        
        // return --
        return (list_of_symbols, list_of_reactions)
    }
    
    private func extractPrecursorSymbolsFromModelStatementArray(_listOfStatements listOfStatements:[String], listOfSymbols:[String]) -> Dictionary<String,[String]> {
    
        // Declarations -
        var precursor_symbol_dictionary = Dictionary<String,[String]>()
        
        // initialize dictionary w/empty arrays -
        for symbol in listOfSymbols {
            
            precursor_symbol_dictionary[symbol] = [String]()
        }
        
        for symbol in listOfSymbols {
            
            for statement_text in listOfStatements {
             
                // does this statement contain a ->
                if (containsString(statement_text, test_string: "->") == true &&
                    containsString(statement_text, test_string: symbol) == true &&
                    containsString(statement_text, test_string: ActionVerb.TRANSLATES.rawValue) == true){
                        
                    // ok, we have a translation context - do we have a list or just a single statement? -and- which side of the arrow are we sitting on?
                    let arrow_split_fragment_array = statement_text.componentsSeparatedByString("->")
                    let product_fragment = arrow_split_fragment_array.last
                    var precursor_fragment = arrow_split_fragment_array.first
                    let tmp = precursor_fragment?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ")
                    precursor_fragment = tmp?.last
                    
                    // Is the symbol a product -or- precursor?
                    if (containsString(product_fragment!, test_string: symbol) == true){
                        
                        // ok, we are a product! We need to get the corresponding precursor -
                        if (containsString(precursor_fragment!, test_string: "(") == true){
                            
                            // ok, we are in a list, need to find my order -
                            let symbol_index_in_product_collection = findIndexOfSymbolInCollectionClause(product_fragment!, symbol:symbol)
                            if (symbol_index_in_product_collection != -1){
                                
                                let value_clause = precursor_fragment!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                                let precursor_symbol_array = value_clause.componentsSeparatedByString(",")
                                let precursor_symbol = precursor_symbol_array[symbol_index_in_product_collection]
                                
                                var tmp_array = precursor_symbol_dictionary[symbol]
                                tmp_array?.append(precursor_symbol)
                                precursor_symbol_dictionary[symbol] = tmp_array
                            }
                        }
                        else {
                            
                            // our parents are *not* in a list ...
                            var tmp_array = precursor_symbol_dictionary[symbol]
                            tmp_array?.append(precursor_fragment!)
                            precursor_symbol_dictionary[symbol] = tmp_array
                        }
                    }
                }
                else if (containsString(statement_text, test_string: "->") == true &&
                    containsString(statement_text, test_string: symbol) == true &&
                    containsString(statement_text, test_string: ActionVerb.TRANSCRIBES.rawValue) == true){
                        
                    // ok, we have a translation context - do we have a list or just a single statement? -and- which side of the arrow are we sitting on?
                    let arrow_split_fragment_array = statement_text.componentsSeparatedByString("->")
                    let product_fragment = arrow_split_fragment_array.last
                    var precursor_fragment = arrow_split_fragment_array.first
                    let tmp = precursor_fragment?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ")
                    precursor_fragment = tmp?.last
                    
                    // Is the symbol a product -or- precursor?
                    if (containsString(product_fragment!, test_string: symbol) == true){
                        
                        // ok, we are a product! We need to get the corresponding precursor -
                        if (containsString(precursor_fragment!, test_string: "(") == true){
                            
                            // ok, we are in a list, need to find my order -
                            let symbol_index_in_product_collection = findIndexOfSymbolInCollectionClause(product_fragment!, symbol:symbol)
                            if (symbol_index_in_product_collection != -1){
                                
                                let value_clause = precursor_fragment!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                                let precursor_symbol_array = value_clause.componentsSeparatedByString(",")
                                let precursor_symbol = precursor_symbol_array[symbol_index_in_product_collection]
                                
                                var tmp_array = precursor_symbol_dictionary[symbol]
                                tmp_array?.append(precursor_symbol)
                                precursor_symbol_dictionary[symbol] = tmp_array
                            }
                        }
                        else {
                            
                            // our parents are *not* in a list ...
                            var tmp_array = precursor_symbol_dictionary[symbol]
                            tmp_array?.append(precursor_fragment!)
                            precursor_symbol_dictionary[symbol] = tmp_array
                        }
                    }
                }
            }
        }
        
        // return -
        return precursor_symbol_dictionary
    }
    
    private func extractSymbolTypeFromModelStatementArray(_listOfStatements listOfStatements:[String], listOfSymbols:[String]) -> Dictionary<String,TypeDescriptor> {
        
        // Declarations -
        var symbol_type_dictionary = Dictionary<String,TypeDescriptor>()
        
        // ok, se need to estimate if a symbol is a mRNA, protein or Metabolite -
        for symbol in listOfSymbols {
            
            // initialize to type other -
            symbol_type_dictionary[symbol] = TypeDescriptor.OTHER
            
            for statement_text in listOfStatements {
             
                // ok, so let's run a series of checks to infer the symbol type -
                // first, lets split around -> if its there ...
                if (containsString(statement_text, test_string: "->") == true){
                    
                    // does this contain transcribes?
                    if (containsString(statement_text, test_string: ActionVerb.TRANSCRIBES.rawValue) == true){
                        
                        // ok, we have a -> type statement! Grab the last element when we split around ->
                        let arrow_split_fragment_array = statement_text.componentsSeparatedByString("->")
                        let product_clause_string = arrow_split_fragment_array.last
                        
                        // Does the product_clause contain the symbol?
                        if (containsString(product_clause_string!, test_string: symbol) == true){
                         
                            // ok, then this symbol is a mRNA -
                            symbol_type_dictionary[symbol] = TypeDescriptor.mRNA
                        }
                    }
                    else if (containsString(statement_text, test_string: ActionVerb.TRANSLATES.rawValue) == true) {
                        
                        // ok, we have a -> type statement! Grab the last element when we split around ->
                        let arrow_split_fragment_array = statement_text.componentsSeparatedByString("->")
                        let product_clause_string = arrow_split_fragment_array.last
                        
                        // Does the product_clause contain the symbol?
                        if (containsString(product_clause_string!, test_string: symbol) == true){
                            
                            // ok, then this symbol is a mRNA -
                            symbol_type_dictionary[symbol] = TypeDescriptor.PROTIEN
                        }
                    }
                    else if (containsString(statement_text, test_string: ActionVerb.CATALYZES.rawValue) == true) {
                        
                        // ok, we have a -> type statement! Grab the last element when we split around ->
                        let arrow_split_fragment_array = statement_text.componentsSeparatedByString("->")
                        let source_clause_string = arrow_split_fragment_array.first!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ").last
                        let product_clause_string = arrow_split_fragment_array.last
                        
                        // Does the product_clause contain the symbol?
                        if (containsString(product_clause_string!, test_string: symbol) == true ||
                            containsString(source_clause_string!,test_string:symbol) == true){
                            
                            // ok, then this symbol is a mRNA -
                            symbol_type_dictionary[symbol] = TypeDescriptor.METABOLITE
                        }
                    }
                }
            }
        }
        
        // return -
        return symbol_type_dictionary
    }
    
    private func extractDefaultParameterValuesFromModelStatementArray(_listOfStatements listOfStatements:[String], listOfSymbols:[String]) -> Dictionary<String,Double> {
        
        // Declarations -
        var default_parameter_value_dictionary = Dictionary<String,Double>()
        
        // build the dictionary w/all symbols w/default value = 0.0
        for local_symbol in listOfSymbols {
            
            default_parameter_value_dictionary[local_symbol] = 0.0
        }
        
        // Correct the parameters w/default values -
        var list_of_verbs = [ActionVerb]()
        list_of_verbs.append(ActionVerb.PARAMETER)
        list_of_verbs.append(ActionVerb.PARAMETERS)

        var list_of_paramter_symbols = extractListOfParameterSymbolsFromModelStatementArray(_listOfStatements: listOfStatements)
        for local_parameter_symbol in list_of_paramter_symbols {
            
            for model_statement in listOfStatements {
             
                // check - does this statement contain *both* the symbol, and either action verbs ..
                if (containsString(model_statement, test_string: local_parameter_symbol) == true &&
                    (containsString(model_statement, test_string: ActionVerb.PARAMETER.rawValue) == true ||
                    containsString(model_statement, test_string: ActionVerb.PARAMETERS.rawValue) == true) &&
                    containsString(model_statement, test_string: "->") == true){
                        
                        // ok, if we get here, then I have a match. Grab *after* the ->
                        var fragment_array = model_statement.componentsSeparatedByString("->")
                        var raw_value_clause = fragment_array.last
                        var value_clause = raw_value_clause!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                        
                        // ok, value_clause could be * or *,*,...,* so we need to check for ,
                        if (containsString(value_clause, test_string: ",") == true){
                            
                            // ok, before we can assign a value, we need to figure out what index we are at ...
                            // Split the model statement along white space -
                            var white_space_split_fragment = model_statement.componentsSeparatedByString(" ")
                            
                            // Remove the ('s -
                            var comma_delimited_symbol_string = white_space_split_fragment.first!.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                            var comma_delimited_symbol_array = comma_delimited_symbol_string.componentsSeparatedByString(",")
                            
                            // What index is my symbol?
                            let index_of_symbol = find(comma_delimited_symbol_array, local_parameter_symbol)
                            
                            // Convert the value clause to an array -
                            var value_clause_array = value_clause.componentsSeparatedByString(",")
                            
                            // Set the value in the dictionary (finally ...) -
                            default_parameter_value_dictionary[local_parameter_symbol] = Double((value_clause_array[index_of_symbol!] as NSString).doubleValue)
                        }
                        else
                        {
                            // Correct the parameter value -
                            default_parameter_value_dictionary[local_parameter_symbol] = Double((value_clause as NSString).doubleValue)
                        }
                    }
                }
            }
        
        
        // return -
        return default_parameter_value_dictionary
    }
    
    private func extractSymbolRoleDictionaryFromModelStatementArray(_listOfStatements listOfStatements:[String], listOfSymbols:[String]) -> Dictionary<String,RoleDescriptor> {
    
        // Declarations -
        var role_dictionary = Dictionary<String,RoleDescriptor>()
        
        // All species will be *DYNANIC* except the parameters -
        
        // build the dictionary w/all DYNAMIC, then correct the CONSTANTS -
        for local_symbol in listOfSymbols {
            
            role_dictionary[local_symbol] = RoleDescriptor.DYNAMIC
        }
        
        // Correct the constants -
        var list_of_paramter_symbols = extractListOfParameterSymbolsFromModelStatementArray(_listOfStatements: listOfStatements)
        for local_parameter_symbol in list_of_paramter_symbols {
            
            role_dictionary[local_parameter_symbol] = RoleDescriptor.CONSTANT
        }
        
        // return -
        return role_dictionary
    }
    
    
    
    private func extractGeneExpressionControlTableFromModelStatementArray(_listOfStatements listOfStatements:[String], listOfOutputSymbols:[String]) -> (control:Matrix,actors:[String]) {
    
        // declarations -
        
        // extract the nouns -
        var verb_symbol_array = [ActionVerb]()
        verb_symbol_array.append(ActionVerb.INDUCES)
        verb_symbol_array.append(ActionVerb.REPRESSES)
        
        
        let (verb_noun_array, index_list) = extractNounSymbolListFromModelStatementArray(_listOfStatements: listOfStatements, verbSymbolArray:verb_symbol_array)
        
        // create the control table -
        var control_table = Matrix(rows:verb_noun_array.count, columns:listOfOutputSymbols.count)
        for action_verb in verb_symbol_array {
            
            // iterate through list of statements with this verb -
            for index in index_list {
                
                // Get statements -
                let model_statement = listOfStatements[index]
                
                // Does this statement contain noun?
                for noun_symbol in verb_noun_array {
                    
                    // Lookup the index of the noun symbol -
                    let index_of_noun_symbol = find(verb_noun_array, noun_symbol)
                    
                    // Does this statement contain the output symbol?
                    for output_symbol in listOfOutputSymbols {
                        
                        if (containsString(model_statement, test_string: output_symbol) == true &&
                            containsString(model_statement, test_string: noun_symbol) == true &&
                            containsString(model_statement, test_string: action_verb.rawValue) == true &&
                            (containsString(model_statement, test_string:ActionVerb.EXPRESSION.rawValue) == true ||
                            containsString(model_statement, test_string:ActionVerb.TRANSCRIPTION.rawValue) == true)) {
                                
                            if (action_verb == ActionVerb.INDUCES){
                                
                                // index for symbol -
                                let index_of_output_symbol = find(listOfOutputSymbols, output_symbol)
                                
                                // update the control_matrix -
                                control_table[index_of_noun_symbol!,index_of_output_symbol!] = 1
                                
                                //println("indcues ...")
                            }
                            else {
                                
                                // index for symbol -
                                let index_of_output_symbol = find(listOfOutputSymbols, output_symbol)
                                
                                // update the control_matrix -
                                control_table[index_of_noun_symbol!,index_of_output_symbol!] = -1
                                
                                //println("represses...")
                                
                            }
                        }
                    }
                }
            }
        }
        

        // return -
        return (control_table,verb_noun_array)
    }
    
    private func extractListOfGenesFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> [String] {
        
        // declarations -
        var list_of_genes = [String]()
        
        // iterate through the list, and look for the action verbs -
        for raw_statement in listOfStatements {
            
            // Does this statement contain 'transcribes'?
            if (raw_statement.rangeOfString("transcribes") != nil) {
                
                
            }
        }
        
        // return -
        return list_of_genes
    }
    
    private func extractListOfParameterSymbolsFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> [String] {
    
        // declarations -
        var list_of_symbols = [String]()
        var list_of_verbs = [ActionVerb]()
        
        // Which verbs do I want to look at?
        list_of_verbs.append(ActionVerb.PARAMETER)
        list_of_verbs.append(ActionVerb.PARAMETERS)
        
        // First, we need to check the list of statements for our infrastructure action verbs, and grab thsee nouns
        for model_statement in listOfStatements {
            
            for action_verb in list_of_verbs {
                
                // ok, does this statement contain my action verb?
                if (containsString(model_statement, test_string: action_verb.rawValue) == true){
                    
                    // ok, grab the fragment to the left in the model statement -
                    let raw_list_of_infrastructure_nouns = cutStatement(model_statement, text_delimiter: " ")[0]
                    
                    // does raw_list_of_infrastructure_nouns contain a (
                    if (containsString(raw_list_of_infrastructure_nouns, test_string: "(") == true){
                        
                        // cut around the ()'s
                        let tmp_raw_list = raw_list_of_infrastructure_nouns.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                        let local_noun_array = tmp_raw_list.componentsSeparatedByString(",")
                        for noun_string in local_noun_array {
                            
                            if (contains(list_of_symbols,noun_string) == false){
                                
                                // ok, raw_list_of_infrastructure_nouns is a * => add to the list_of_symbols
                                list_of_symbols.append(noun_string)
                            }
                        }
                    }
                    else
                    {
                        if (contains(list_of_symbols,raw_list_of_infrastructure_nouns) == false){
                            
                            // ok, raw_list_of_infrastructure_nouns is a * => add to the list_of_symbols
                            list_of_symbols.append(raw_list_of_infrastructure_nouns)
                        }
                    }
                }
            }
        }
        
        // return -
        return list_of_symbols
    }
    
    private func extractListOfInfrastructureSymbolsFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> [String] {
        
        // declarations -
        var list_of_symbols = [String]()
        var list_of_verbs = [ActionVerb]()
        
        // Which verbs do I want to look at?
        list_of_verbs.append(ActionVerb.TRANSCRIBES)
        list_of_verbs.append(ActionVerb.TRANSLATES)
        list_of_verbs.append(ActionVerb.PARAMETER)
        list_of_verbs.append(ActionVerb.PARAMETERS)
        
        // First, we need to check the list of statements for our infrastructure action verbs, and grab thsee nouns
        for model_statement in listOfStatements {
        
            for action_verb in list_of_verbs {
             
                // ok, does this statement contain my action verb?
                if (containsString(model_statement, test_string: action_verb.rawValue) == true){
                 
                    // ok, grab the fragment to the left in the model statement -
                    let raw_list_of_infrastructure_nouns = cutStatement(model_statement, text_delimiter: " ")[0]
                    
                    // does raw_list_of_infrastructure_nouns contain a (
                    if (containsString(raw_list_of_infrastructure_nouns, test_string: "(") == true){
                        
                        // cut around the ()'s
                        let tmp_raw_list = raw_list_of_infrastructure_nouns.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                        let local_noun_array = tmp_raw_list.componentsSeparatedByString(",")
                        for noun_string in local_noun_array {
                            
                            if (contains(list_of_symbols,noun_string) == false){
                                
                                // ok, raw_list_of_infrastructure_nouns is a * => add to the list_of_symbols
                                list_of_symbols.append(noun_string)
                            }
                        }
                    }
                    else
                    {
                        if (contains(list_of_symbols,raw_list_of_infrastructure_nouns) == false){
                            
                            // ok, raw_list_of_infrastructure_nouns is a * => add to the list_of_symbols
                            list_of_symbols.append(raw_list_of_infrastructure_nouns)
                        }
                    }
                }
            }
        }
        
        // return -
        return list_of_symbols
    }
    
    private func extractListOfProteinsFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> [String] {
        
        // declarations -
        var list_of_proteins = [String]()
        
        // iterate through the list, and look for the action verbs -
        for raw_statement in listOfStatements {
            
            // Does this statement contain 'transcribes'?
            if (containsString(raw_statement, test_string: "translates")) {
                
                // ok, we have a transcribes, right of the -> gives the mRNA list -
                var fragment_array = cutStatement(raw_statement, text_delimiter: "->")
                
                // the right hand side is the (mX...mY) list -
                if (containsString(fragment_array[1],test_string: "(")){
                    
                    // remove first, and last char -
                    var tmp_list = (fragment_array[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                    
                    // split around ,
                    var protein_symbol_array = cutStatement(tmp_list, text_delimiter: ",")
                    for protein_symbol in protein_symbol_array {
                        if (contains(list_of_proteins,protein_symbol) == false){
                            list_of_proteins.append(protein_symbol)
                        }
                    }
                }
                else
                {
                    // we have a single mRNA?
                    list_of_proteins.append(fragment_array[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                }
            }
            else if (raw_statement.rangeOfString("translation", options:NSStringCompareOptions.CaseInsensitiveSearch,
                range:Range<String.Index>(start: raw_statement.startIndex, end: raw_statement.endIndex), locale:nil) != nil){
                    
                    // ok, we have a transcription statements, to the right of -> gives mRNA
                    
            }
        }
        
        // return -
        return list_of_proteins
    }
    
    private func extractListOfmRNAsFromModelStatementArray(_listOfStatements listOfStatements:[String]) -> [String] {
        
        // declarations -
        var list_of_mRNAs = [String]()
        
        // iterate through the list, and look for the action verbs -
        for raw_statement in listOfStatements {
            
            // Does this statement contain 'transcribes or expression'?
            if (containsString(raw_statement, test_string:ActionVerb.TRANSCRIBES.rawValue) == true ||
                containsString(raw_statement, test_string:ActionVerb.EXPRESSION.rawValue) == true) {
                
                // ok, we have a transcribes, right of the -> gives the mRNA list -
                var fragment_array = cutStatement(raw_statement, text_delimiter: "->")
                
                // the right hand side is the (mX...mY) list -
                if (containsString(fragment_array[1],test_string: "(")){
                    
                    // remove first, and last char -
                    var tmp_list = (fragment_array[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                    
                    // split around ,
                    var mRNA_symbol_array = cutStatement(tmp_list, text_delimiter: ",")
                    for mRNA_symbol in mRNA_symbol_array {
                        if (contains(list_of_mRNAs,mRNA_symbol) == false){
                            list_of_mRNAs.append(mRNA_symbol)
                        }
                    }
                }
                else
                {
                    // we have a single mRNA?
                    list_of_mRNAs.append(fragment_array[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                }
            }
        }
        
        // return -
        return list_of_mRNAs
    }

    
    // - MARK: Helper functions
    private func findIndexOfSymbolInCollectionClause(collectionClause:String,symbol:String) -> Int {
    
        // Declarations -
        var index_of_symbol = -1
        
        // remove spaces and ('
        var value_clause = collectionClause.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
        var fragment_array = value_clause.componentsSeparatedByString(",")
        if let local_index_of_symbol = find(fragment_array,symbol){
            index_of_symbol = local_index_of_symbol
        }
        
        // return -
        return index_of_symbol
    }
    
    
    private func extractNounSymbolForModelStatement(modelStatement:String,verbSymbol:ActionVerb) -> (nouns:[String],indexes:[Int]) {
    
        // Declarations -
        var list_of_noun_symbols = [String]()
        var index_array = [Int]()
        
        // Wrap the statement in an array -
        var statement_array = [String]()
        statement_array[0] = modelStatement
        
        // call -
        //let return_array = self.extractNounSymbolListFromModelStatementArray(_listOfStatements: statement_array, verbSymbol: verbSymbol)
        //list_of_noun_symbols = return_array.nouns
        //index_array = return_array.indexes
        
        // return -
        return (list_of_noun_symbols, index_array)
    }
    
    private func extractNounSymbolListFromModelStatementArray(_listOfStatements listOfStatements:[String], verbSymbolArray:[ActionVerb]) -> (nouns:[String],indexes:[Int]) {
        
        // declarations -
        var list_of_noun_symbols = [String]()
        var index_array = [Int]()
        
        
        for action_verb in verbSymbolArray {
            
            // iterate through the list of commands, find those with the verbSymbol and then get the noun -
            var index = 0
            for statement_line in listOfStatements {
                
                if (containsString(statement_line, test_string: action_verb.rawValue) == true) {
                    
                    // ok, split along whitespace, take the first symbol -
                    var tmp_fragment_array = statement_line.componentsSeparatedByString(" ")
                    var local_noun_symbol = tmp_fragment_array[0]
                    
                    // Does my local list of nouns have (***) or * form?
                    if (containsString(local_noun_symbol, test_string: "(") == true){
                        
                        // we have a (***) list = remove the ()'s and then split along the ,
                        let remove_parens = local_noun_symbol.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                        let local_noun_list = remove_parens.componentsSeparatedByString(",")
                        
                        // add to the symbol list -
                        for noun_symbol in local_noun_list {
                            
                            if (contains(list_of_noun_symbols,noun_symbol) == false){
                                list_of_noun_symbols.append(noun_symbol)
                            }
                        }
                    }
                    else {
                        
                        if (contains(list_of_noun_symbols,local_noun_symbol) == false){
                            list_of_noun_symbols.append(local_noun_symbol)
                        }
                    }
                    
                    // cache the index of the statement -
                    index_array.append(index)
                }
                
                // update the index -
                index++
            }
        }
        
        
        // return -
        return (list_of_noun_symbols, index_array)
    }

    
    private func containsString(text_statement:String,test_string:String) -> Bool {
        
        // declarations -
        var return_flag = false
        
        // do a string comparison -
        if (text_statement.rangeOfString(test_string, options: NSStringCompareOptions.CaseInsensitiveSearch,
            range: Range<String.Index>(start: text_statement.startIndex, end: text_statement.endIndex), locale:nil) != nil){
                
                // if we get here, then we contain the string -
                return_flag = true
        }
        
        // return -
        return return_flag
    }
    
    private func cutStatement(text_statement:String,text_delimiter:String) -> [String] {
        
        // declarations -
        var fragment_array:[String]
        
        // cut -
        fragment_array = text_statement.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(text_delimiter)
        
        // return -
        return fragment_array
    }
    
}
