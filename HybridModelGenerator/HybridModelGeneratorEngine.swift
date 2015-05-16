//
//  HybridModelGeneratorEngine.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/22/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa
import Foundation

enum ModelCodeLanguage {
    
    case LANGUAGE_OCATVE_M
    case LANGUAGE_OCTAVE_C
    case LANGUAGE_MATLAB_M
    case LANGUAGE_JULIA
}


class HybridModelGeneratorEngine: NSObject {
    
    // declarations -
    private var myModelInputURL:NSURL
    private var myModelOutputURL:NSURL
    private var myModelCodeLanguage:ModelCodeLanguage

    // status update block type called passed in when calling doExecute 
    // used to update the GUI
    typealias codeGenerationJobStatusUpdateBlock = (NSDictionary)->()
    
    init(inputURL:NSURL,outputURL:NSURL,language:ModelCodeLanguage){
        
        self.myModelInputURL = inputURL
        self.myModelOutputURL = outputURL
        self.myModelCodeLanguage = language
    }
    
    // MARK: Factor method -
    func executeCodeGenerationStrategyStrategy(context:HybridModelContext,strategy:CodeStrategy) -> String {
        
        // return -
        return strategy.execute(context)
    }
    
    func processStrategyModelFileDictionary(hybridModelContext:HybridModelContext,modelDictionary:Dictionary<String,CodeStrategy>,statusUpdateBlock:codeGenerationJobStatusUpdateBlock) -> Void {
        
        var message_dictionary = Dictionary<String,String>()
        
        // process the files in the dictionary -
        for (model_file_name,strategy_impl) in modelDictionary {
            
            // build the URL -
            var model_file_url = self.myModelOutputURL.URLByAppendingPathComponent(model_file_name)
            
            // get the code buffer -
            var code_buffer = executeCodeGenerationStrategyStrategy(hybridModelContext, strategy: strategy_impl) as String
            
            // write the buffre to disk -
            code_buffer.writeToURL(model_file_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil)
            
            // update the GUI
            message_dictionary["MESSAGE_KEY"] = "Wrote \(model_file_name) to \(model_file_url) \n"
            statusUpdateBlock(message_dictionary)
        }
    }
    
    
    // main method -
    func doExecute(statusUpdateBlock:codeGenerationJobStatusUpdateBlock)-> Void {
        
        // declarations -
        var input_file_parser:HybridModelNaturalLanguageParser
        var model_context:HybridModelContext
        var message_dictionary:NSMutableDictionary = NSMutableDictionary()
        let start_time = CFAbsoluteTimeGetCurrent()
        
        // parse the input file -> returns a HybridModelContext
        input_file_parser = HybridModelNaturalLanguageParser(_inputURL: self.myModelInputURL)
        model_context = input_file_parser.parse()
        
        // Notify the user -
        message_dictionary["MESSAGE_KEY"] = "Loaded the input file. Created the model context object\n"
        statusUpdateBlock(message_dictionary)
        
        // Hand the HybridModelContext to a series of methods that depend upon the 
        // language
        if (ModelCodeLanguage.LANGUAGE_OCATVE_M == self.myModelCodeLanguage){
        
            // read the input file, create model_context -
            let hybrid_model_context = input_file_parser.parse()
            
            // ok, we have the model context, we need to write the associate data files to the outputURL
            // For octave-m, we need DataFile.m, ControlFile.m, Kinetics.m, BalanceEquations.m, and SolveBalanceEquations.m
            
            message_dictionary["MESSAGE_KEY"] = "Starting to build code ... \n"
            statusUpdateBlock(message_dictionary)
            
            // ok, we need to set a few things on the CodeLib -
            HybridModelOctaveMCodeLibrary.my_input_url = self.myModelInputURL
            
            // Array for files we need to generate -
            var dictionary_of_model_files = Dictionary<String,CodeStrategy>()
            dictionary_of_model_files["Kinetics.m"] = KineticsOctaveMStrategy()
            dictionary_of_model_files["DataFile.m"] = DataFileOctaveMStrategy()
            dictionary_of_model_files["Balances.m"] = BalanceEquationsOctaveMStrategy()
            dictionary_of_model_files["SolveBalanceEquations.m"] = SolveBalanceEquationsOctaveMStrategy()
            dictionary_of_model_files["Control.m"] = ControlOctaveMStrategy()
            
            // process the dictionary -
            processStrategyModelFileDictionary(hybrid_model_context,modelDictionary: dictionary_of_model_files,statusUpdateBlock: statusUpdateBlock)
            
            // get elapsed time -
            let elapsed_time = timeElapsedInSecondsWhenRunningCode(start_time)
            message_dictionary["MESSAGE_KEY"] = "Completed code generation run in \(elapsed_time)s \n"
            statusUpdateBlock(message_dictionary)

        }
        else if (ModelCodeLanguage.LANGUAGE_JULIA == self.myModelCodeLanguage){
            
            // read the input file, create model_context -
            let hybrid_model_context = input_file_parser.parse()
            
            // ok, we need to set a few things on the CodeLib -
            HybridModelJuliaCodeLibrary.my_input_url = self.myModelInputURL
            
            // Array for files we need to generate -
            var dictionary_of_model_files = Dictionary<String,CodeStrategy>()
            dictionary_of_model_files["Kinetics.jl"] = KineticsJuliaStrategy()
            dictionary_of_model_files["DataFile.jl"] = DataFileJuliaStrategy()
            dictionary_of_model_files["Balances.jl"] = BalanceEquationsJuliaStrategy()
            dictionary_of_model_files["SolveBalanceEquations.jl"] = SolveBalanceEquationsJuliaStrategy()
            dictionary_of_model_files["Control.jl"] = ControlJuliaStrategy()
            dictionary_of_model_files["Project.jl"] = ProjectIncludeFileJuliaStrategy()
            
            // process the dictionary -
            processStrategyModelFileDictionary(hybrid_model_context,modelDictionary: dictionary_of_model_files,statusUpdateBlock: statusUpdateBlock)
            
            // get elapsed time -
            let elapsed_time = timeElapsedInSecondsWhenRunningCode(start_time)
            message_dictionary["MESSAGE_KEY"] = "Completed code generation run in \(elapsed_time)s \n"
            statusUpdateBlock(message_dictionary)
        }
        else
        {
            // Notify the user -
            message_dictionary["MESSAGE_KEY"] = "ERROR: Ooops! Model code type is not supported. Job terminated.\n"
            statusUpdateBlock(message_dictionary)
        }
    }
    
    
    // MARK: Helper functions
    func timeElapsedInSecondsWhenRunningCode(startTime:CFAbsoluteTime) -> Double {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return Double(timeElapsed)
    }
}
