//
//  VLEMParser.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol GrammarStrategy {
    
    func parse(scanner:VLEMScanner) -> VLError?
}


class VLEMParser: NSObject {
    
    // declarations -
    private var scanner:VLEMScanner?
    private var myModelInputURL:NSURL
    private var file_name:String?
    private var sentence_array:[VLEMSentenceWrapper]?
    
    // Initialize an *empty* error array -
    var myParserErrorArray:[VLError] = [VLError]()

    init(inputURL:NSURL){
        
        self.myModelInputURL = inputURL
        
        // what is the file name?
        if let local_file_name = inputURL.lastPathComponent {
            self.file_name = local_file_name
        }
    }
    
    // MARK: - Main tree creation method 
    func buildAbstractSyntaxTree() -> SyntaxTreeComposite? {
        
        // Declarations -
        var scanner:VLEMScanner?
        var model_root:SyntaxTreeComposite = SyntaxTreeComposite(type:TokenType.ROOT)
        
        // hidden helper functions -
        
        
        // ok, so we have consumed all the tokens
        if let sentence_array = self.sentence_array {
            
            // Iterate through the sentence array -
            for sentence_wrapper in sentence_array {
                
                // create scanner -
                scanner = VLEMScanner(sentenceWrapper: sentence_wrapper)
                
                // Scan the sentence -
                let return_scanner_data = scanner!.scanSentence()
                
                // did this parse ok?
                let did_scan_succed = return_scanner_data.success
                if (did_scan_succed == true) {
                    
                    let action_token_type = scanner!.getActionTokenType()
                    if (action_token_type == TokenType.EXPRESSION || action_token_type == TokenType.TRANSCRIPTION){
                        
                        // If we get here then we have a expression sentence, so we need to make an expression tree.
                        // The first node we create is a transcription node -
                        var transcription_node = buildTranscriptionStatementControlTreeWithScanner(scanner!)
                       
                        // Add the transcription node the root -
                        model_root.addNodeToTree(transcription_node)
                    }
                }
            }
        }
        
        return model_root
    }
    
    
    // MARK: - Tree node creation methods
    func buildTranscriptionStatementControlTreeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
        
        // Declarations -
        var transcription_node = SyntaxTreeComposite(type: TokenType.TRANSCRIPTION)
        
        // What type of control do we have?
        var control_node = buildControlStatementNodeWithScanner(scanner)
        
        // What symbols are associated with the control node?
        if let first_token = scanner.getNextToken() {
            
            if (first_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // Ok, we have a simple statement - create an OR, add the species to it, and then add OR to control node
                var or_node = SyntaxTreeComposite(type: TokenType.OR)
                
                // Create species component node -
                var species_component = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                species_component.lexeme = first_token.lexeme
                
                // Add species to OR node -
                or_node.addNodeToTree(species_component)
                
                // Add OR to CONTROL node -
                control_node.addNodeToTree(or_node)
            }
            else if (first_token.token_type == TokenType.LPAREN){
                
                // ok, so we have a more complicated situation.
                // We have a (species AND species) -or- (species OR species) clause 
                if var relationship_subtree = buildRelationshipSubtreeNodeWithScanner(scanner,node: nil) {
                    
                    // add relationship subtree to control node -
                    control_node.addNodeToTree(relationship_subtree)
                }
            }
        }
        
        // Process the target clause - (the remainder of the tokens in the scanner)
        if let target_clause_token = scanner.getNextToken() {
            
            if (target_clause_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
            }
            else if (target_clause_token.token_type == TokenType.LPAREN){
                
            }
        }
        
        
        // add control node to transcription node -
        transcription_node.addNodeToTree(control_node)
        
        // return -
        return transcription_node
    }
    
    
    func buildRelationshipSubtreeNodeWithScanner(scanner:VLEMScanner,node:SyntaxTreeComponent?) -> SyntaxTreeComponent? {
        
        if let next_token = scanner.getNextToken() {
            
            if (next_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // ok, create symbol node -
                var symbol_leaf = SyntaxTreeComponent(type: TokenType.BIOLOGICAL_SYMBOL)
                symbol_leaf.lexeme = next_token.lexeme
                
                if let local_parent_node = node as? SyntaxTreeComposite {
                    
                    // add my leaf to the node that was passed in -
                    local_parent_node.addNodeToTree(symbol_leaf)
                    
                    // ok, let's keep going, call me with the leaf that I just created -
                    return buildRelationshipSubtreeNodeWithScanner(scanner, node:local_parent_node)
                }
                
                // ok, let's keep going, call me with the leaf that I just created -
                return buildRelationshipSubtreeNodeWithScanner(scanner, node: symbol_leaf)
            }
            else if (next_token.token_type == TokenType.AND ||
                    next_token.token_type == TokenType.OR){
             
                // ok, we have a relationship, do we have a node that was passed in?
                if let local_node = node {
                    
                    var relationship_node = SyntaxTreeComposite(type: next_token.token_type!)
                    relationship_node.lexeme = next_token.lexeme
                    
                    // ok, grab the node that was passed in -
                    relationship_node.addNodeToTree(local_node)
                    
                    // call me again -
                    return buildRelationshipSubtreeNodeWithScanner(scanner, node: relationship_node)
                }
            }
            else if (next_token.token_type == TokenType.RPAREN)
            {
                return node
            }
        }
     
        // no more tokens?
        return nil
    }
    
    func buildControlStatementNodeWithScanner(scanner:VLEMScanner) -> SyntaxTreeComposite {
    
        // what type of control node do we have?
        
        // Get the "control" type (induce, induces etc)
        let control_token_type = scanner.getControlTokenType()
        
        // Create the control node -
        var control_node = SyntaxTreeComposite(type: control_token_type)
        
        // return my control node -
        return control_node
    }
    

    
    // MARK: - Main parse method
    func parse() -> (success:Bool,error:[VLError]?) {
    
        // ok, load the file up -
        var scanner:VLEMScanner?
        
        // ok, if we have any sentences, we need to parse them and check to see of the syntax is correct.
        if let sentence_array = loadSentences() where (sentence_array.count>0) {
            
            // grab the sentence array for later -
            self.sentence_array = sentence_array
            
            // Iterate through the sentence array -
            for sentence_wrapper in sentence_array {
                
                // create scanner -
                scanner = VLEMScanner(sentenceWrapper: sentence_wrapper)
                
                // Scan the sentence -
                let return_scanner_data = scanner!.scanSentence()
                
                // did this parse ok?
                let did_scan_succed = return_scanner_data.success
                if (did_scan_succed == true) {
                    
                    // ok, if we get here, then I need to do a few things.
                    // First, I need to figure out what grammar we have ...
                    // Next, we need to pass that Grammar, and our token list to an appropriate parser function to check
                    // If our program is legit.
                    // Last, we need to constuct the AST (abstract syntax tree) that will be crawled to generate our code.
                    
                    // we need to figure out what grammar to use -
                    let action_token_type = scanner!.getActionTokenType()
                    if (action_token_type == TokenType.EXPRESSION || action_token_type == TokenType.TRANSCRIPTION){
                        
                        // We have an expression statement -
                        doParseWithGrammarAndScanner(scanner!, grammar:ExpressionStatementGrammarStrategy())
                    }
                }
                else {
                    
                    // need to handle the error here ...
                    // ok, we have a some type of scanner error. Grab the error instance and store in the error array -
                    if let local_error_object = return_scanner_data.error {
                        myParserErrorArray.append(local_error_object)
                    }
                }
            }
        }
        else {
            
            // We have an empty file w/no sentences ...
            // Create error -
            let error_object = VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain: "VLEMParser", userInfo:nil)
             myParserErrorArray.append(error_object)
        }
        
        // ok, we've scanned the source code, and we parsed the source code do we have any errors?
        if (myParserErrorArray.count>0){
            return (false,myParserErrorArray)
        }
        else {
            return (true,nil)
        }
    }
    
    // MARK: - Helper methods
    private func loadSentences() -> [VLEMSentenceWrapper]? {
    
        var local_model_sentences:[VLEMSentenceWrapper]?
        var line_counter = 1
    
        // load raw text -
        let raw_model_buffer = String(contentsOfURL: self.myModelInputURL, encoding:NSUTF8StringEncoding, error: nil)
    
        // Ok, we need to ignore comments, and split the string -
        if let component_array = raw_model_buffer?.componentsSeparatedByString("\n") {
            
            // Create array -
            local_model_sentences = [VLEMSentenceWrapper]()
            
            // iterate through the lines, and put into an array. Get rid of empty lines, and lines that
            // start with //
            for raw_text_line in component_array {
                
                if (raw_text_line.isEmpty == false && !(raw_text_line ~= /"^//[A-Za-z0-9 ].*")){
                    
                    // create a sentence wrapper -
                    var sentence_wrapper = VLEMSentenceWrapper(sentence:raw_text_line,lineNumber:line_counter)
                    
                    // add to the array -
                    local_model_sentences!.append(sentence_wrapper)
                    
                }
                
                // update the line counter -
                line_counter = line_counter + 1
            }
        }
    
        
        // return the sentence array -
        return local_model_sentences
    }
    
    private func doParseWithGrammarAndScanner(scanner:VLEMScanner,grammar:GrammarStrategy) -> Void {
        
        if let error = grammar.parse(scanner) {
            
            // cache the error in the error array -
            myParserErrorArray.append(error)
            
            let user_information = error.userInfo
            if (VLErrorCode.MISSION_TOKEN_ERROR == error.code){
                
                let method_name = user_information["METHOD"]
                println("Opps - error found: Missing token in method \(method_name)")
            }
            else if (VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR == error.code){
                
                if let location = user_information["LOCATION"], method_name = user_information["METHOD"], message = user_information["MESSAGE"] {
                    println("Ooops! Error in method \(method_name) found at \(location). \(message)")
                }
            }
        }
        else {
            println("Parse succeded!")
        }
    }
}
