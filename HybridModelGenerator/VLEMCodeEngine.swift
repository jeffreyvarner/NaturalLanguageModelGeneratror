//
//  VLEMCodeEngine.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/5/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum ModelCodeLanguage {
    
    case LANGUAGE_OCATVE_M
    case LANGUAGE_MATLAB_M
    case LANGUAGE_OCTAVE_C
    case LANGUAGE_GSL_C
    case LANGUAGE_JULIA
    case LANGUAGE_PYTHON
    case LANGUAGE_SBML
    case LANGUAGE_DOT
    
    static let language_array = [LANGUAGE_OCATVE_M,LANGUAGE_MATLAB_M,LANGUAGE_OCTAVE_C,LANGUAGE_GSL_C,LANGUAGE_JULIA,LANGUAGE_PYTHON,LANGUAGE_SBML,LANGUAGE_DOT]
}

class VLEMCodeEngine: NSObject {

    // declarations -
    private var myModelInputURL:NSURL
    private var myModelOutputURL:NSURL
    private var myModelCodeLanguage:ModelCodeLanguage
    
    init(inputURL:NSURL,outputURL:NSURL,language:ModelCodeLanguage){
        
        self.myModelInputURL = inputURL
        self.myModelOutputURL = outputURL
        self.myModelCodeLanguage = language
    }
    
    // MARK: - Factory method impl    
    private func generateModelCodeFromAbstractSyntaxTreeAndStrategy(abstractSyntaxTree:SyntaxTreeComponent,strategy:CodeGenerationStrategy) -> String {
        
        // return -
        return strategy.execute(abstractSyntaxTree)
    }
    
    func generate(abstractSyntaxTree:SyntaxTreeComponent,modelDictionary:Dictionary<String,CodeGenerationStrategy>) -> Void {
        
        // process the files in the dictionary -
        for (model_file_name,strategy_impl) in modelDictionary {
            
            // build the URL -
            var model_file_url = self.myModelOutputURL.URLByAppendingPathComponent(model_file_name)
            
            // get the code buffer -
            var code_buffer = generateModelCodeFromAbstractSyntaxTreeAndStrategy(abstractSyntaxTree, strategy: strategy_impl) as String
            
            // write the buffre to disk -
            code_buffer.writeToURL(model_file_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil)
        }
    }
}
