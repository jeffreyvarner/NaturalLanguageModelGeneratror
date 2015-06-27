//
//  VLEMMessageLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

typealias MessageKey = String

class VLEMMessageLibrary: NSObject {
    
    static let VLEM_COMPILER_INPUT_URL_MESSAGE = "VLEM_COMPILER_INPUT_URL_MESSAGE"
    static let VLEM_COMPILER_OUTPUT_URL_MESSAGE = "VLEM_COMPILER_OUTPUT_URL_MESSAGE"
    static let VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE = "VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE"
    static let VLEM_COMPILER_ERROR_MESSAGE = "VLEM_COMPILER_ERROR_MESSAGE"
    static let VLEM_COMPILER_START_MESSAGE = "VLEM_COMPILER_START_MESSAGE"
    static let VLEM_COMPILER_COMPLETION_MESSAGE = "VLEM_COMPILER_COMPLETION_MESSAGE"
}

struct VLEMCompilerStartMessage:Message {
    
    // special init -
    init(){
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_START_MESSAGE
    }
    
    func messagePayload() -> Any? {
        
        return nil
    }
}

struct VLEMCompilerCompletionMessage:Message {
    
    // special init -
    init(){
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_COMPLETION_MESSAGE
    }
    
    func messagePayload() -> Any? {
        
        return nil
    }
}


struct VLEMCompilerOutputLanguageMessage:Message {
    
    // Static strings, used as the messageKey -
    private let _dictionary:Dictionary<MessageKey,ModelCodeLanguage>?
    
    // special init -
    init(payload:Dictionary<MessageKey,ModelCodeLanguage>){
        _dictionary = payload
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE
    }
    
    func messagePayload() -> Any? {
        
        if let _local_dictionary = _dictionary {
            return _local_dictionary[self.messageKey()]
        }
        
        return nil
    }
}

struct VLEMCompilerOutputURLMessage:Message {
    
    // Static strings, used as the messageKey -
    private let _dictionary:Dictionary<MessageKey,NSURL>?
    
    // special init -
    init(payload:Dictionary<MessageKey,NSURL>){
        _dictionary = payload
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_OUTPUT_URL_MESSAGE
    }
    
    func messagePayload() -> Any? {
        
        if let _local_dictionary = _dictionary {
            return _local_dictionary[self.messageKey()]
        }
        
        return nil
    }
}

struct VLEMCompilerInputURLMessage:Message {
    
    // Static strings, used as the messageKey -
    private let _dictionary:Dictionary<MessageKey,NSURL>?
    
    // special init -
    init(payload:Dictionary<MessageKey,NSURL>){
        _dictionary = payload
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_INPUT_URL_MESSAGE
    }
    
    func messagePayload() -> Any? {
        
        if let _local_dictionary = _dictionary {
            return _local_dictionary[self.messageKey()]
        }
        
        return nil
    }
}

struct VLEMCompilerErrorMessage:Message {
    
    // Static strings, used as the messageKey -
    private let _dictionary:Dictionary<MessageKey,Array<VLError>>?
    
    // special init -
    init(payload:Dictionary<MessageKey,Array<VLError>>){
        _dictionary = payload
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_ERROR_MESSAGE
    }
    
    func messagePayload() -> Any? {
        
        if let _local_dictionary = _dictionary {
            return _local_dictionary[self.messageKey()]
        }
        
        return nil
    }
}