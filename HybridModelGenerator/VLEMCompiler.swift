//
//  VLEMCompiler.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/25/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

private let _compiler = VLEMCompiler()

class VLEMCompiler: Subscriber {

    // declarations -
    private var _parser:VLEMParser?
    private var _my_input_url:NSURL?
    private var _my_output_url:NSURL?
    
    private var _dictionary_of_model_files = Dictionary<String,CodeGenerationStrategy>()
    
    
    // no init -
    private init() {
        println("Private compiler init being called ...")
    }
    
    // Inner class for a singleton ... how does this work?
    class var sharedCompiler : VLEMCompiler
    {
        return _compiler
    }
    
    // ok, message system protocol -
    func receive(#message: Message) -> Void {
        
        // what language are we generating the model in?
        
        
        
        // ok, we need to listen for input URL messages -
        if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_INPUT_URL_MESSAGE){
         
            // ok, we have a URL message type. We need to grab the input and output URLs for the compiler -
            if let _url_array = message.messagePayload() as? [NSURL] {
                
                // the first url is the input url, while the second url is the output -
                _my_input_url = _url_array[0]
                _my_output_url = _url_array[1]
                
                // ok, build the parser -
                _parser = VLEMParser(inputURL:_my_input_url!)
                
                // If we have the parser - then execute compile step
                if (_parser != nil) {
                    
                    let return_data = _parser!.parse()
                    if (return_data.success == true){
                        
                        // ok, the input was parsed ok, Let's have the parser build the
                        // syntax tree for this file...
                        var model_tree = _parser!.buildAbstractSyntaxTree()
                        var code_engine:VLEMCodeEngine = VLEMCodeEngine(inputURL:_my_input_url!, outputURL:_my_output_url!, language: ModelCodeLanguage.LANGUAGE_JULIA)
                        code_engine.generate(model_tree!, modelDictionary: _dictionary_of_model_files)
                    }
                    else {
                        
                    }
                }
            }
        }
    }
}
