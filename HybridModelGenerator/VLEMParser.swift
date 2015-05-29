//
//  VLEMParser.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol GrammerStrategy {
    
    func parse(scanner:VLEMScanner) -> VLError?
}


class VLEMParser: NSObject {
    
    // declarations -
    private var scanner:VLEMScanner?
    private var myModelInputURL:NSURL
    private var file_name:String?
    
    init(inputURL:NSURL){
        
        self.myModelInputURL = inputURL
        
        // what is the file name?
        if let local_file_name = inputURL.lastPathComponent {
            self.file_name = local_file_name
        }
    }
    
    // main method
    func parse() -> Void {
    
        // Initialize an *empty* error array -
        var myParserErrorArray:[VLError] = [VLError]()
        
        // ok, load the file up -
        var scanner:VLEMScanner?
        
        // ok, if we have any sentences, we need to parse them and check to see of the syntax is correct.
        if let sentence_array = loadSentences() where (sentence_array.count>0) {
            
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
                    // Next, we need to pass that Grammer, and our token list to an appropriate parser function to check
                    // If our program is legit.
                    // Last, we need to constuct the AST (abstract syntax tree) that will be crawled to generate our code.
                    
                    // for now we *know* that we have an induce statement ...
                    doParseWithGrammerAndScanner(scanner!, grammar:InduceStatementStrategy())
                    
                }
                else {
                    
                    // need to handle the error here ...
                    // ok, we have an error. Grab the error instance and store in the error array -
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
        
        // ok, we've scanned the source code, do we have any errors?
        if (myParserErrorArray.count>0){
            
            // oops, it appears we have some parser errors in the code. report the line numbers.
            for error_object in myParserErrorArray {
                
                if let line_number = error_object.userInfo["LINE_NUMBER"],
                    let bad_token = error_object.userInfo["OFFENDING_TOKEN"] {
                    
                    if let local_file_name = file_name {
                        var error_description:String = "ERROR in \(local_file_name) at L\(line_number): Illegal symbol \(bad_token)"
                        println(error_description)
                    }
                    else {
                        var error_description:String = "ERROR at L\(line_number): Illegal symbol \(bad_token)"
                        println(error_description)
                    }
                }
            }
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
                
                if (raw_text_line.isEmpty == false && !(raw_text_line ~= /"^[/#].+")){
                    
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
    
    private func doParseWithGrammerAndScanner(scanner:VLEMScanner,grammar:GrammerStrategy) -> Void {
        
        if let error = grammar.parse(scanner) {
            
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
            println("No error ...?")
        }
    }
}
