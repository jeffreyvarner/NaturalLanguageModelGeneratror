//
//  ViewController.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa


class ViewController: NSViewController,Subscriber {
    
    // instance variables -
    private var myInputFileURL:NSURL?
    private var myOutputFileURL:NSURL?
    private var _messageBroker = VLEMMessageBroker.sharedMessageBroker
    
    // outlets -
    @IBOutlet var myModelBlueprintOpenFileActionButton:NSButton?
    @IBOutlet var myModelGenerateActionButton:NSButton?
    @IBOutlet var myModelGenerateCancelActionButton:NSButton?
    @IBOutlet var myModelFilePathTextField:NSTextField?
    @IBOutlet var myModelOutputFilePathTextField:NSTextField?
    @IBOutlet var myModelOutputOpenFileActionButton:NSButton?
    @IBOutlet var myModelStatusTextView:NSTextView?
    @IBOutlet var myModelLanguagePopUpMenu:NSPopUpButton?
    
    // engines -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myModelStatusTextView?.editable = false
        
        // ok, so we need to subscribe to the error messages coming from the compiler -
        // I would rather do this in the app delegate ... I don't want the VC to know anything about anything ...
        // however, for now let's put it here -
        _messageBroker.subscribe(self, messageKey:VLEMMessageLibrary.VLEM_COMPILER_ERROR_MESSAGE)
    }

    override var representedObject: AnyObject? {
        
        didSet {
        // Update the view, if already loaded.
        }
    }

    // helper methods -
    private func changeGenerateButtonStatus() -> Bool {
        
        // variables -
        var return_flag = false
        
        // check, do we have *both* URLs?
        if (myInputFileURL != nil && myOutputFileURL != nil){
            return_flag = true
        }
        
        // return 
        return return_flag
    }
    
    // MARK: - Subscriber protocol methods
    func receive(#message: Message) -> Void {
        
        // ok, we recieved a message! Figure out the type, decode and execute
        if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_ERROR_MESSAGE){
            
            // ok, we have a compiler error message. For this type of message, we expect an array
            // of errors -
            
        }
    }
    
    
    // MARK: - IBOutlet actions
    @IBAction func myModelGenerateActionButtonWasPushed(button:NSButton){
        
        // parser -
        var code_engine:VLEMCodeEngine = VLEMCodeEngine(inputURL: myInputFileURL!, outputURL:myOutputFileURL!, language: ModelCodeLanguage.LANGUAGE_JULIA)
        var parser:VLEMParser = VLEMParser(inputURL:myInputFileURL!)
        
        // Array for files we need to generate -
        var dictionary_of_model_files = Dictionary<String,CodeGenerationStrategy>()
        dictionary_of_model_files["DataFile.jl"] = JuliaDataFileFileStrategy()
        dictionary_of_model_files["SolveBalanceEquations.jl"] = JuliaSolveBalanceEquationsFileStrategy()
        dictionary_of_model_files["Project.jl"] = JuliaProjectIncludeFileStrategy()
        dictionary_of_model_files["Balances.jl"] = JuliaBalanceEquationsFileStrategy()
        dictionary_of_model_files["Control.jl"] = JuliaControlFileStrategy()
        dictionary_of_model_files["Kinetics.jl"] = JuliaKineticsFileStrategy()
        
        // execute the parse function -
        let return_data = parser.parse()
        if (return_data.success == true){
            
            // ok, the input was parsed ok, Let's have the parser build the
            // syntax tree for this file...
            var model_tree = parser.buildAbstractSyntaxTree()
            code_engine.generate(model_tree!, modelDictionary: dictionary_of_model_files)
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
    
//    @IBAction func myModelGenerateActionButtonWasPushed(button:NSButton){
//        
//        // ok -- if we get here, both URLs are populated. We to need to load the data into the engine, and start the code 
//        // generation process
//        
//        // what is my model type?
//        let index_language_type = myModelLanguagePopUpMenu?.indexOfSelectedItem
//        var my_language_type = ModelCodeLanguage.LANGUAGE_OCATVE_M
//        if (index_language_type == 0){
//            
//            my_language_type = ModelCodeLanguage.LANGUAGE_OCATVE_M
//        }
//        else {
//            my_language_type = ModelCodeLanguage.LANGUAGE_JULIA
//        }
//        
//        // build the engine -
//        var model_generation_engine = HybridModelGeneratorEngine(inputURL: self.myInputFileURL!,
//            outputURL: self.myOutputFileURL!,language: my_language_type)
//        
//        // specify the completion status block -
//        var completion_handler = {
//            [weak self](status_dictionary:NSDictionary) -> Void in
//            
//            // get the message from the dictionary -
//            var message_string:NSString = status_dictionary["MESSAGE_KEY"] as! NSString
//            
//            // update the text area -
//            if let weak_self = self {
//               
//                weak_self.myModelStatusTextView!.string! += String(message_string)
//            }
//        }
//        
//        // generate the code -
//        model_generation_engine.doExecute(completion_handler)
//    }
    
    @IBAction func myModelOutputOpenFileActionButtonWasPushed(button:NSButton){
        
        // Declarations -
        var myOpenFilePanel:NSOpenPanel = NSOpenPanel()
        
        // Set attributes on openPanel -
        myOpenFilePanel.allowsMultipleSelection = false
        myOpenFilePanel.canChooseDirectories = true
        myOpenFilePanel.canCreateDirectories = true
        myOpenFilePanel.canChooseFiles = false
        
        // set the focus -
        self.myModelOutputFilePathTextField?.becomeFirstResponder()
        
        // Setup completion handler -
        var myCompletionHandler = {
            [weak self](result:Int) -> Void in
            
            if let weak_self = self {
            
                // do we have ok?
                if (result == NSFileHandlingPanelOKButton){
                    
                    // ok -- grab the dir
                    weak_self.myOutputFileURL = myOpenFilePanel.URL
                    
                    // Set the text on text field -
                    let url_string:NSString? = myOpenFilePanel.URL?.absoluteString
                    if let local_url_string = url_string {
                        weak_self.myModelOutputFilePathTextField?.stringValue = local_url_string as String
                        
                        // no edit -
                        weak_self.myModelOutputFilePathTextField?.editable = false
                        
                        // update the generate button?
                        if (weak_self.changeGenerateButtonStatus()){
                         
                            weak_self.myModelGenerateActionButton?.enabled = true
                            
                        }
                    }
                }
            }
        }
        
        // open the panel ...
        myOpenFilePanel.beginSheetModalForWindow(self.view.window!, completionHandler:myCompletionHandler)
        
    }
    
    @IBAction func myModelBlueprintOpenInputFileActionButtonWasPushed(button:NSButton){
        
        // Declarations -
        var myOpenFilePanel:NSOpenPanel = NSOpenPanel()
        
        // Set attributes on openPanel -
        myOpenFilePanel.allowsMultipleSelection = false
        myOpenFilePanel.canChooseDirectories = false
        myOpenFilePanel.canCreateDirectories = false
        myOpenFilePanel.canChooseFiles = true
        
        // set the focus -
        self.myModelFilePathTextField?.becomeFirstResponder()
        
        // Setup completion handler -
        var myCompletionHandler = {
            [weak self](result:Int) -> Void in
            
            if let weak_self = self {
            
                if (result == NSFileHandlingPanelOKButton){
                    
                    // ok - we have pushed the ok button
                    weak_self.myInputFileURL = myOpenFilePanel.URL
                    
                    // Set the text on text field -
                    let url_string:NSString? = myOpenFilePanel.URL?.absoluteString
                    if let local_url_string = url_string {
                        weak_self.myModelFilePathTextField?.stringValue = local_url_string as String
                        
                        // no edit -
                        weak_self.myModelFilePathTextField?.editable = false
                        
                        // update the generate button?
                        if (weak_self.changeGenerateButtonStatus()){
                            
                            weak_self.myModelGenerateActionButton?.enabled = true
                            
                        }
                    }
                }
            }
        }
        
        // open the panel ...
        myOpenFilePanel.beginSheetModalForWindow(self.view.window!, completionHandler:myCompletionHandler)
    }
}

