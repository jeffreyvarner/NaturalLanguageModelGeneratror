//
//  ViewController.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum UserStatusMessageType {
    
    case NOMINAL_MESSAGE
    case ERROR_MESSAGE
}

class ViewController: NSViewController,Subscriber {
    
    // instance variables -
    private var myInputFileURL:NSURL?
    private var myOutputFileURL:NSURL?
    private var compile_start_date:NSDate?
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
        _messageBroker.subscribe(self, messageKey: VLEMMessageLibrary.VLEM_COMPILER_COMPLETION_MESSAGE)
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
            // full of crunchy errors -
            if let _error_array = message.messagePayload() as? [VLError] {
                
                for error in _error_array {
                 
                    let user_information = error.userInfo
                    if (VLErrorCode.MISSION_TOKEN_ERROR == error.code){
                        
                        let method_name = user_information["METHOD"]
                        println("Opps - error found: Missing token in method \(method_name)")
                    }
                    else if (VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR == error.code || VLErrorCode.INCORRECT_GRAMMAR_ERROR == error.code){
                        
                        if let location = user_information["LOCATION"], method_name = user_information["METHOD"], message = user_information["MESSAGE"], class_name = user_information["CLASS"] {
                            let error_message = "Ooops! A syntax error was detected while processing the model statetment at \(location).\nThe error was detected by the \(method_name) method of the \(class_name) class.\n\(message).\n"
                            postStringMessageToTextView(error_message, type: UserStatusMessageType.ERROR_MESSAGE)
                        }
                    }
                    else if (VLErrorCode.ILLEGAL_CHARACTER_ERROR == error.code){
                        
                        if let _bad_token = user_information["TOKEN"] {
                            
                            // What is the input file?
                            if let _last_url_component = myInputFileURL?.lastPathComponent {
                                let text_message = "Ooops! The scanner does not understand the symbol \"\(_bad_token)\". Please check the input file \"\(_last_url_component)\"\n"
                                println(text_message)
                                postStringMessageToTextView(text_message, type: UserStatusMessageType.ERROR_MESSAGE)
                            }
                            else {
                                println("Ooops! The scanner does not understand the symbol \"\(_bad_token)\". Please check your input file.")
                            }
                        }
                    }
                }
            }
        }
        else if (message.messageKey() == VLEMMessageLibrary.VLEM_COMPILER_COMPLETION_MESSAGE){
            
            // ok, we recieved the completion message -
            
            // calculate the elapsed time -
            let compiler_end_date = NSDate()
            let timeInterval: Double = compiler_end_date.timeIntervalSinceDate(compile_start_date!);
            
            // post to textview -
            var completion_message = "Model code generation was succesfully generated in \(timeInterval) s \n"
            postStringMessageToTextView(completion_message, type: UserStatusMessageType.NOMINAL_MESSAGE)
        }
    }
    
    
    // MARK: - IBOutlet actions
    @IBAction func myModelGenerateActionButtonWasPushed(button:NSButton){
    
        // ok, so we need to post the required data to the compiler, and then send the start button -
        
        // Get the message broker -
        let _broker = VLEMMessageBroker.sharedMessageBroker
        
        // For now only Julia -
        let _language = ModelCodeLanguage.LANGUAGE_JULIA
        
        // do we have all of the required data?
        if let _input_url = myInputFileURL, _output_url = myOutputFileURL {
            
            // Input URL message -
            var payload_dictionary_input_url = [VLEMMessageLibrary.VLEM_COMPILER_INPUT_URL_MESSAGE:_input_url]
            var input_url_message = VLEMCompilerInputURLMessage(payload: payload_dictionary_input_url)
            _broker.publish(message: input_url_message)
            
            // Output URL message -
            var payload_dictionary_output_url = [VLEMMessageLibrary.VLEM_COMPILER_OUTPUT_URL_MESSAGE:_output_url]
            var output_url_message = VLEMCompilerOutputURLMessage(payload: payload_dictionary_output_url)
            _broker.publish(message: output_url_message)
            
            // Model language message -
            var payload_dictionary_model_language = [VLEMMessageLibrary.VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE:_language]
            var language_message = VLEMCompilerOutputLanguageMessage(payload: payload_dictionary_model_language)
            _broker.publish(message: language_message)
            
            // Let the user know that we are starting ...
            let url_string:NSString? = _input_url.lastPathComponent
            if let local_url_string = url_string {
                var starting_message = "Sending \"\(local_url_string)\" to the compiler ... trying to generate Julia code\n"
                postStringMessageToTextView(starting_message, type: UserStatusMessageType.NOMINAL_MESSAGE)
            }
            
            // Start message -
            compile_start_date = NSDate()
            var start_message = VLEMCompilerStartMessage()
            _broker.publish(message: start_message)
        }
        else {
            
            // Post error to user -
            // ...
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
    
    // MARK: - Helper methods
    private func postStringMessageToTextView(message:String,type:UserStatusMessageType){
        
        // ok, what type is this?
        if (type == UserStatusMessageType.ERROR_MESSAGE){
            
            let attrString = NSAttributedString (
                string: message,
                attributes: [NSForegroundColorAttributeName:NSColor.redColor()])
            
            self.myModelStatusTextView!.textStorage?.appendAttributedString(attrString)
        }
        else {
            
            // We have a nominal message -
            self.myModelStatusTextView?.string! += String(message)
        }
        
        // add new line -
        // self.myModelStatusTextView?.string! += String("\n")
    }
}

