//
//  AppDelegate.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // app wide services -
    private var _messageBroker = VLEMMessageBroker.sharedMessageBroker
    private var _compiler = VLEMCompiler.sharedCompiler

    func applicationDidFinishLaunching(aNotification: NSNotification) {
    
        // ok, the application is up and running -
        
        // Let's configure the message system ...
        _messageBroker.subscribe(_compiler, messageKey: VLEMMessageLibrary.VLEM_COMPILER_INPUT_URL_MESSAGE)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

