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
    private var _my_model_language_type:ModelCodeLanguage?
    
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
        if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_START_MESSAGE){
            
            // ok, we've been sent a compiler start message. However, we need to check to see
            // if we have all the requird data
            if (_my_model_language_type != nil && _my_input_url != nil && _my_output_url != nil){
            
                // ok, looks like we *may* be ok -
                
                // ok, build the parser -
                _parser = VLEMParser(inputURL:_my_input_url!)
                
                // If we have the parser - then execute compile step
                if (_parser != nil) {
                    
                    let return_data = _parser!.parse()
                    if (return_data.success == true){
                        
                        // ok, the input was parsed ok, Let's have the parser build the
                        // syntax tree for this file...
                        var model_tree = _parser!.buildAbstractSyntaxTree()
                        
                        // Build the code engine -
                        var code_engine:VLEMCodeEngine = VLEMCodeEngine(inputURL:_my_input_url!, outputURL:_my_output_url!, language: ModelCodeLanguage.LANGUAGE_JULIA)
                        
                        // generate the code
                        code_engine.generate(model_tree!, modelDictionary: _dictionary_of_model_files)
                        
                        // ok, so we have completed the job - send completion message -
                        VLEMMessageBroker.sharedMessageBroker.publish(message: VLEMCompilerCompletionMessage())
                    }
                    else {
                 
                        // Uh oh ... We have compiler errors!
                        if let _error_array = return_data.error {
                            
                            // create the payload -
                            var payload_dictionary:Dictionary<MessageKey,Array<VLError>> = [VLEMMessageLibrary.VLEM_COMPILER_ERROR_MESSAGE : _error_array]
                            
                            // Post the error message -
                            var error_message = VLEMCompilerErrorMessage(payload: payload_dictionary)
                            VLEMMessageBroker.sharedMessageBroker.publish(message: error_message)
                        }
                    }
                }
            }
            else {
                // send error back - we don't have all the required data to start the compiler -
            }
        }
        else if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_OUTPUT_URL_MESSAGE) {
            
            // ok, we have a URL message type. We need to grab the input and output URLs for the compiler -
            if let _url_value = message.messagePayload() as? NSURL {
                _my_output_url = _url_value
            }
        }
        else if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE){
         
            if let _model_language_value = message.messagePayload() as? ModelCodeLanguage {
                _my_model_language_type = _model_language_value
                
                // load specific types of strategies depending uppn the language type -
                if (_my_model_language_type == ModelCodeLanguage.LANGUAGE_JULIA){
                    
                    _dictionary_of_model_files["DataFile.jl"] = JuliaDataFileFileStrategy()
                    _dictionary_of_model_files["SolveBalanceEquations.jl"] = JuliaSolveBalanceEquationsFileStrategy()
                    _dictionary_of_model_files["Project.jl"] = JuliaProjectIncludeFileStrategy()
                    _dictionary_of_model_files["Balances.jl"] = JuliaBalanceEquationsFileStrategy()
                    _dictionary_of_model_files["Control.jl"] = JuliaControlFileStrategy()
                    _dictionary_of_model_files["Kinetics.jl"] = JuliaKineticsFileStrategy()
                }
            }
        }
        else if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_INPUT_URL_MESSAGE){
         
            // ok, we have a URL message type. We need to grab the input and output URLs for the compiler -
            if let _url_value = message.messagePayload() as? NSURL {
                
                // the first url is the input url, while the second url is the output -
                _my_input_url = _url_value
            }
        }
    }
}
