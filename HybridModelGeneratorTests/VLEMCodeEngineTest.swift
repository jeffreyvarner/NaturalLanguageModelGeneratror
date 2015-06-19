//
//  VLEMCodeEngineTest.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa
import XCTest

class VLEMCodeEngineTest: XCTestCase {

    
    // Declarations -
    let test_network_path = "/Users/jeffreyvarner/Desktop/HybridModelTest/Test.net"
    let test_network_output_path = "/Users/jeffreyvarner/Desktop/HybridModelTest/test_compiler"
    var code_engine:VLEMCodeEngine?
    var parser:VLEMParser?
    
    override func setUp() {
        super.setUp()
        
        // make the URL -
        let test_url = NSURL(fileURLWithPath: test_network_path)
        let test_output_url = NSURL(fileURLWithPath: test_network_output_path)
        
        // build a scanner, use space as the delimiter -
        parser = VLEMParser(inputURL:test_url!)
        code_engine = VLEMCodeEngine(inputURL: test_url!, outputURL:test_output_url!, language: ModelCodeLanguage.LANGUAGE_JULIA)
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGenerateFunction() -> Void {
    
        // Array for files we need to generate -
        var dictionary_of_model_files = Dictionary<String,CodeGenerationStrategy>()
        dictionary_of_model_files["DataFile.jl"] = JuliaDataFileFileStrategy()
        dictionary_of_model_files["SolveBalanceEquations.jl"] = JuliaSolveBalanceEquationsFileStrategy()
        dictionary_of_model_files["Project.jl"] = JuliaProjectIncludeFileStrategy()
        dictionary_of_model_files["Balances.jl"] = JuliaBalanceEquationsFileStrategy()
        dictionary_of_model_files["Control.jl"] = JuliaControlFileStrategy()
        dictionary_of_model_files["Kinetics.jl"] = JuliaKineticsFileStrategy()
       
        // execute -
        // execute the parse function -
        if let local_parser = parser {
            let return_data = local_parser.parse()
            if (return_data.success == true){
                
                // ok, the input was parsed ok, Let's have the parser build the
                // syntax tree for this file...
                var model_tree = local_parser.buildAbstractSyntaxTree()
                if let local_model_tree = model_tree, local_code_engine = code_engine {
                    
                    local_code_engine.generate(local_model_tree, modelDictionary: dictionary_of_model_files)
                }
            }
            else {
                
                // ok, we have some errors ...
                if let _error_array = return_data.error {
                    
                    for error in _error_array {
                        
                        let user_information = error.userInfo
                        if (VLErrorCode.MISSION_TOKEN_ERROR == error.code){
                            
                            let method_name = user_information["METHOD"]
                            println("Opps - error found: Missing token in method \(method_name)")
                        }
                        else if (VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR == error.code || VLErrorCode.INCORRECT_GRAMMAR_ERROR == error.code){
                            
                            if let location = user_information["LOCATION"], method_name = user_information["METHOD"], message = user_information["MESSAGE"] {
                                println("Ooops! Error in method \(method_name) found at \(location). \(message)")
                            }
                        }
                    }
                }
            }
        }
    }
}
