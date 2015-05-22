//
//  VLEMScanner.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/20/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

enum VLErrorCode {
    
    case EMPTY_SENTENCE_ERROR
    case EMPTY_DELIMITER_ERROR
    case ILLEGAL_DELIMITER_ERROR
    case ILLEGAL_CHARACTER_ERROR
    case TOKEN_ARRAY_BOUNDS_ERROR
    
}

struct VLError {
    
    typealias ErrorInfoDictionary = Dictionary<String,String>
    
    let code: VLErrorCode
    let domain: String
    let userInfo: ErrorInfoDictionary
    
    init(code:VLErrorCode , domain: String, userInfo: ErrorInfoDictionary?) {
        
        self.code = code
        self.domain = domain
        if let info = userInfo {
            self.userInfo = info
        }
        else
        {
            self.userInfo = [String:String]()
        }
    }
}

prefix operator / {}
prefix func / (regex: String) -> NSRegularExpression {
    return NSRegularExpression(pattern: regex, options: nil, error: nil)!
}

func ~=(string: String, regex: NSRegularExpression) -> Bool {
    let range = NSMakeRange(0, count(string))
    return (regex.firstMatchInString(string,options:NSMatchingOptions.allZeros,range:range) != nil)
}

class VLEMScanner: NSObject {
    
    // Declarations -
    private var model_sentence:String?
    lazy private var token_array:[String] = [String]()
    private var token_index = 0
    private var delimiter:String
    
    init(sentenceDelimiter:String) {
        
        self.delimiter = sentenceDelimiter
    }
    
    
    func scanSentence(sentenceWrapper:VLEMSentenceWrapper) -> (success:Bool,error:VLError?) {
        
        // ok, unwrap the sentence -
        let sentence = sentenceWrapper.sentence
        
        // tokenize the sentence -
        let local_return_data = scanSentence(sentence)
        
        // ok, did this work of not?
        let scan_succeded_flag = local_return_data.success
        if (scan_succeded_flag == true)
        {
            return local_return_data
        }
        else {
            // ok, it didn't work ... bummer.
            // Grab the user dictionary, and add the line number to it -
            let line_number = sentenceWrapper.line_number
            if let local_user_error = local_return_data.error {
                
                // Update the dictionary -
                var updated_user_info = local_user_error.userInfo
                updated_user_info["LINE_NUMBER"] = String(line_number)
                
                // make a copy of the error -
                var updated_error_object = VLError(code: local_user_error.code, domain: local_user_error.domain, userInfo:updated_user_info)
                return(false,updated_error_object)
            }
            
            return (false,local_return_data.error)
        }
    }
    
    func hasMoreSentenceTokens() -> Bool {
        
        let number_of_tokens = token_array.count
        if (token_index>number_of_tokens - 1){
            return false
        }
        else {
            return true
        }
    }
    
    func getNextSentenceToken() -> String? {
    
        // declarations -
        var token_string:String?
     
        // how many elements do we have in the token array?
        let number_of_tokens = token_array.count
        if (token_index>number_of_tokens - 1){
            
            // ERROR - notify the user, we are requesting a token index that doesn't exist
            // TODO: Implement error code
            
            // return nil -
            return token_string
        }
        else {
            
            // ok, so we a token to return
            let local_token_value = token_array[token_index++]
            return local_token_value
        }
    }
    
    func printSentenceTokens() -> Void {
        
        for sentence_token in token_array {
            println("TOKEN:\(sentence_token)")
        }
    }
    
    // MARK: - Private helper functions
    private func resetTokenIndexToStartOfSentence() -> Void {
        self.token_index = 0
    }
    
    private func scanSentence(sentence:String) -> (success:Bool,error:VLError?) {
        
        
        // ok, do we have a legit sentence?
        if (sentence.isEmpty == true || delimiter.isEmpty == true){
            
            // ERROR: Notify the user that we are trying to tokenize an empty string
            if (sentence.isEmpty) {
                
                return (false,VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain:"VLEMScanner", userInfo: nil))
                
            }
            else {
                return (false,VLError(code: VLErrorCode.EMPTY_DELIMITER_ERROR, domain:"VLEMScanner", userInfo: nil))
            }
        }
        
        // grab the sentence -
        self.model_sentence = sentence
        
        // cut the sentence up - first, clear the token_array, then reset the counter -
        if (token_array.count>0){
            token_array.removeAll(keepCapacity: true)
            
            // reset the counter -
            resetTokenIndexToStartOfSentence()
        }
        
        // split around the delimiter -
        let local_token_array = sentence.componentsSeparatedByString(self.delimiter)
        for sentence_token in local_token_array {
            
            // ok, before we grab this token, let's check to see if we have
            // any crazy illegal chars in token. If not, then we can store it, if so we
            // stop and return an error -
            // [^A-Za-z0-9_>)-,].*
            if (sentence_token ~= /"^[A-Za-z0-9\\(-].*" && !(sentence_token ~= /"[%\\*].*")) {
                
                println("OK \(sentence_token)")
                
                // ok, we do *not* have any special characters -
                self.token_array.append(sentence_token)
            }
            
            else {
                
                // Oops, some type of special character in the token. Note, we could have the -> token which is legit.
                // Does this token *start* witn a lowercase, and upper case letter *and* contain an illegal char?
                
                // Create user dictionary -
                let user_dictionary = ["OFFENDING_TOKEN":sentence_token]
                return (false,VLError(code: VLErrorCode.ILLEGAL_CHARACTER_ERROR, domain:"VLEMScanner",userInfo:user_dictionary))
            }
        }
        
        // return -
        return (true,nil)
    }
}
