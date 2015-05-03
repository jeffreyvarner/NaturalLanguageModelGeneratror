//
//  ViewController.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // instance variables -
    private var myInputFileURL:NSURL?
    private var myOutputFileURL:NSURL?
    
    // outlets -
    @IBOutlet var myModelBlueprintOpenFileActionButton:NSButton?
    @IBOutlet var myModelGenerateActionButton:NSButton?
    @IBOutlet var myModelGenerateCancelActionButton:NSButton?
    @IBOutlet var myModelFilePathTextField:NSTextField?
    @IBOutlet var myModelOutputFilePathTextField:NSTextField?
    @IBOutlet var myModelOutputOpenFileActionButton:NSButton?
    @IBOutlet var myModelStatusTextView:NSTextView?
    
    // engines -
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myModelStatusTextView?.editable = false
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
    
    // actions --
    @IBAction func myModelGenerateActionButtonWasPushed(button:NSButton){
        
        // ok -- if we get here, both URLs are populated. We to need to load the data into the engine, and start the code 
        // generation process
        
        // build the engine -
        var model_generation_engine = HybridModelGeneratorEngine(inputURL: self.myInputFileURL!,
            outputURL: self.myOutputFileURL!,language: ModelCodeLanguage.LANGUAGE_OCATVE_M)
        
        // specify the completion status block -
        var completion_handler = {
            [weak self](status_dictionary:NSDictionary) -> Void in
            
            // get the message from the dictionary -
            var message_string:NSString = status_dictionary["MESSAGE_KEY"] as NSString
            
            // update the text area -
            if let weak_self = self {
               
                weak_self.myModelStatusTextView!.string! += String(message_string)
            }
        }
        
        // generate the code -
        model_generation_engine.doExecute(completion_handler)
    }
    
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
                        weak_self.myModelOutputFilePathTextField?.stringValue = local_url_string
                        
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
                        weak_self.myModelFilePathTextField?.stringValue = local_url_string
                        
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

