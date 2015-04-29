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
    
    // main method -
    func doExecute(statusUpdateBlock:codeGenerationJobStatusUpdateBlock)-> Void {
        
        // declarations -
        var input_file_parser:HybridModelNaturalLanguageParser
        var model_context:HybridModelContext
        var message_dictionary:NSMutableDictionary = NSMutableDictionary()
        
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
            
            // DataFile.m -
            var data_file_object = HybridModelDataFileObject(context: hybrid_model_context,strategy: DataFileOctaveMStrategy())
            var data_file_buffer:String = data_file_object.doExecute()
            var data_file_url = self.myModelOutputURL.URLByAppendingPathComponent("DataFile.m")
            data_file_buffer.writeToURL(data_file_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil);
            
            // SolveBalanceEquations.m -
            var solve_balance_equations_object = HybridModelSolveBalanceEquationsFileObject(context:hybrid_model_context, strategy:SolveBalanceEquationsOctaveMStrategy())
            var solve_balances_buffer:String = solve_balance_equations_object.doExecute()
            var solve_balances_url = self.myModelOutputURL.URLByAppendingPathComponent("SolveBalanceEquations.m")
            solve_balances_buffer.writeToURL(solve_balances_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil);
            
            // BalanceEquations.m -
            var balance_equations_object = HybridModelBalanceEquationsFileObject(context:hybrid_model_context, strategy:BalanceEquationsOctaveMStrategy())
            var balances_buffer:String = balance_equations_object.doExecute()
            var balances_url = self.myModelOutputURL.URLByAppendingPathComponent("Balances.m")
            balances_buffer.writeToURL(balances_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil);
            
            // Control.m -
            var control_equations_object = HybridModelControlFileObject(context:hybrid_model_context, strategy:ControlOctaveMStrategy())
            var control_buffer:String = control_equations_object.doExecute()
            var control_url = self.myModelOutputURL.URLByAppendingPathComponent("Control.m")
            control_buffer.writeToURL(control_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil)
            
            // Kinetics.m -
            var kinetic_equations_object = HybridModelKineticsFileObject(context:hybrid_model_context, strategy:KineticsOctaveMStrategy())
            var kinetic_buffer:String = kinetic_equations_object.doExecute()
            var kinetic_url = self.myModelOutputURL.URLByAppendingPathComponent("Kinetics.m")
            kinetic_buffer.writeToURL(kinetic_url, atomically:true, encoding: NSUTF8StringEncoding, error: nil)
        }
        else
        {
            // Notify the user -
            message_dictionary["MESSAGE_KEY"] = "ERROR: Ooops! Model code type is not supported. Job terminated.\n"
            statusUpdateBlock(message_dictionary)
        }
    }
}