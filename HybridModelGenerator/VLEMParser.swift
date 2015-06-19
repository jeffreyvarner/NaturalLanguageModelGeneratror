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
                        
                        // need to remove the action token -
                        if (!scanner!.removeTokenOfType(TokenType.EXPRESSION)){
                            scanner!.removeTokenOfType(TokenType.TRANSCRIPTION)
                        }
                    
                        // If we get here then we have a expression sentence, so we need to make an expression tree.
                        // The first node we create is a transcription node -
                        var builder = TranscriptionSyntaxTreeBuilderLogic()
                        var transcription_node = builder.build(scanner!)
                       
                        // Add the transcription node the root -
                        model_root.addNodeToTree(transcription_node)
                    }
                    else if (scanner!.getTypeTokenType() == TokenType.TYPE){
                        
                        // ok, we have a type assignmnet -
                        // I know thw first and last tokens are what we need
                        var builder = TypeAssignmentSyntaxTreeBuilderLogic()
                        var type_tree = builder.build(scanner!)
                        
                        // Add this type to the tree -
                        model_root.addNodeToTree(type_tree)
                    }
                }
            }
        }
        
        return model_root
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
                        if let _error = doParseWithGrammarAndScanner(scanner!, grammar:ExpressionStatementGrammarStrategy()){
                            myParserErrorArray.append(_error)
                        }
                    }
                    else if (scanner!.getTypeTokenType() == TokenType.TYPE){
                        
                        // ok, we have a TYPE token, so this must be a type of assingment -
                        if let _error = doParseWithGrammarAndScanner(scanner!, grammar: TypeAssignmentStatementGrammarStrategy()){
                            myParserErrorArray.append(_error)
                        }
                    }
                    else {
                        
                        // We don't have a grammer strategy for this sentence ... build an error
                        var error_information_dictionary = Dictionary<String,String>()
                        error_information_dictionary["TOKEN"] = sentence_wrapper.sentence
                        error_information_dictionary["LOCATION"] = "Line: \(sentence_wrapper.line_number) col: 1"
                        error_information_dictionary["MESSAGE"] = "Incorrect statement. Found: \(sentence_wrapper.sentence). We do not understand this sentence."
                        error_information_dictionary["METHOD"] = "parse"
                        error_information_dictionary["CLASS"] = "VLEMParser"
                        let local_error_object = VLError(code: VLErrorCode.INCORRECT_GRAMMAR_ERROR, domain: "VLEMParser", userInfo: error_information_dictionary)
                        
                        // cache the error -
                        myParserErrorArray.append(local_error_object)
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
    
    private func doParseWithGrammarAndScanner(scanner:VLEMScanner,grammar:GrammarStrategy) -> VLError? {
        return grammar.parse(scanner)
    }
}
