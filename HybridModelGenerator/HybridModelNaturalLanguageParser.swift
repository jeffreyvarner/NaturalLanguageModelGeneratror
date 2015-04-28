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
    case PARAMETERS = "PARAMETERS"
    case PARAMETER = "PARAMETER"
}

enum RoleDescriptor:String {
    
    case CONSTANT = "constant"
    case DYNAMIC = "dynamic"
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
        
        // Extract gene expression control table -
        var (gene_expression_control_table, effector_array) = extractGeneExpressionControlTableFromModelStatementArray(_listOfStatements: local_model_commands,listOfOutputSymbols: mRNA_array)
        
        
        // build the state array -
        var state_array = mRNA_array+protein_array+infrastructure_and_parameter_array+effector_array
        for state_symbol in state_array {
            model_context.addStateSymbolsToModelContext(state_symbol)
        }
        
        // Grab the *unique* state array -
        let unique_state_symbol_array = model_context.state_symbol_array
        
        // Populate the model context -
        model_context.gene_expression_control_matrix = gene_expression_control_table
        model_context.gene_expression_effector_array = effector_array
        model_context.gene_expression_output_array = mRNA_array
        
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
        
        // set the state model -
        model_context.state_model_dictionary = state_model_dictionary
        
        // return the context -
        return model_context
    }
    
    
    
    // --- Extract * methods --
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
                            containsString(model_statement, test_string: action_verb.rawValue) == true) {
                                
                            if (action_verb == ActionVerb.INDUCES){
                                
                                // index for symbol -
                                let index_of_output_symbol = find(listOfOutputSymbols, output_symbol)
                                
                                // update the control_matrix -
                                control_table[index_of_noun_symbol!,index_of_output_symbol!] = 1
                                
                                println("indcues ...")
                            }
                            else {
                                
                                // index for symbol -
                                let index_of_output_symbol = find(listOfOutputSymbols, output_symbol)
                                
                                // update the control_matrix -
                                control_table[index_of_noun_symbol!,index_of_output_symbol!] = -1
                                
                                println("represses...")
                                
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
            
            // Does this statement contain 'transcribes'?
            if (containsString(raw_statement, test_string: "transcribes")) {
                
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
            else if (raw_statement.rangeOfString("transcription", options:NSStringCompareOptions.CaseInsensitiveSearch,
                range:Range<String.Index>(start: raw_statement.startIndex, end: raw_statement.endIndex), locale:nil) != nil){
                
                // ok, we have a transcription statements, to the right of -> gives mRNA
                    
            }
        }
        
        // return -
        return list_of_mRNAs
    }

    
    // --- Helper functions ---
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
        fragment_array = text_statement.componentsSeparatedByString(text_delimiter)
        
        // return -
        return fragment_array
    }
    
}
