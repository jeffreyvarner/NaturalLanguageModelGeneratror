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
    static let VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE = "VLEM_COMPILER_OUTPUT_LANGUAGE_MESSAGE"
    static let VLEM_COMPILER_ERROR_MESSAGE = "VLEM_COMPILER_ERROR_MESSAGE"
    
}



struct VLEMURLMessage:Message {
    
    // Static strings, used as the messageKey -
    
    private let _dictionary:Dictionary<MessageKey,Any>
    
    // special init -
    init(payload:Dictionary<MessageKey,Any>){
        _dictionary = payload
    }
    
    // Protocol methods -
    func messageKey() -> MessageKey
    {
        return VLEMMessageLibrary.VLEM_COMPILER_INPUT_URL_MESSAGE
    }
    
    func messagePayload() -> Any? {
        return _dictionary[self.messageKey()]
    }
}