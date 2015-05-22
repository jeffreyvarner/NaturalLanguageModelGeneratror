//
//  VLEMParser.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

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
        var scanner = VLEMScanner(sentenceDelimiter: " ")
        
        // ok, if we have any sentences, we need to parse them and check to see of the syntax is correct.
        if let sentence_array = loadSentences() {
            
            for sentence_wrapper in sentence_array {
                
                // Scan the sentence -
                let return_scanner_data = scanner.scanSentence(sentence_wrapper)
                
                // did this parse ok?
                let did_scan_succed = return_scanner_data.success
                if (did_scan_succed == true) {
                    
                    
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
                
                if (raw_text_line.isEmpty == false && !(raw_text_line ~= /"^//.*")){
                    
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
}
