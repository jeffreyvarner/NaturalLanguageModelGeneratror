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

enum TokenType {
    
    case IF
    case AND
    case OR
    case COMMA
    case VERT
    case IS
    case A
    case THE
    
    case INDUCES
    case INDUCE
    case REPRESSES
    case REPRESS
    case ACTIVATES
    case ACTIVATE
    case INHIBITS
    case INHIBIT
    case TRANSCRIPTION
    case TRANSLATION
    case TRANSCRIBES
    case TRANSCIBE
    case TRANSLATES
    case TRANSLATE
    case SYSTEM
    case TRANSFERED
    case TRANSFER
    case TO
    case FROM
    case PARAMETER
    
    case BIOLOGICAL_SYMBOL
    case GENERATES_SYMBOL
    case LPAREN
    case RPAREN
    case RNAP
    case RIOBOSOME
    case DLIT
    case ILIT
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

struct VLEMToken {
    
    // declarations -
    var token_type:TokenType?
    var line_number = 0
    var column_number = 0
    var lexeme:String?
    var value:Float?
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
    lazy private var token_array:[VLEMToken] = [VLEMToken]()
    private var token_index = 0
    private var my_sentence_wrapper:VLEMSentenceWrapper
    private var model_sentence:String?
    
    init(sentenceWrapper:VLEMSentenceWrapper) {
        self.my_sentence_wrapper = sentenceWrapper
    }
    
    
    func scanSentence() -> (success:Bool,error:VLError?) {
        
        // ok, unwrap the sentence -
        let sentence = my_sentence_wrapper.sentence
        let line_number = my_sentence_wrapper.line_number
        
        // tokenize the sentence -
        let local_return_data = scanSentenceAtLineNumber(sentence,lineNumber: line_number)
        
        return (true,nil)
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
        return nil
    }
    
    func printSentenceTokens() -> Void {
        
    }
    
    // MARK: - Private helper functions
    private func resetTokenIndexToStartOfSentence() -> Void {
        self.token_index = 0
    }
    
    private func scanSentenceAtLineNumber(sentence:String,lineNumber:Int) -> (success:Bool,error:VLError?) {
        
        // helper stuff -
        let whitespace_set = NSCharacterSet.whitespaceCharacterSet()
        
        // ok, do we have a legit sentence?
        if (sentence.isEmpty == true){
            
            // ERROR: Notify the user that we are trying to tokenize an empty sentence ...
            return (false,VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain:"VLEMScanner", userInfo: nil))
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
        var column_index = 0
        var local_character_stack = [Character]()
        for sentence_character in sentence {
            
            
            // ok, we need to do a bunch of checks ...
            
            // first is this char legit?
            // TODO: Check for legit chars here?
            
            // ok, first - is this character a *single char token* ?
            if sentence_character == "(" {
                
                // ok, we have a LPAREN - build the token, add to the array -
                let token = VLEMToken(token_type:TokenType.LPAREN, line_number: lineNumber, column_number: column_index, lexeme: "(", value: nil)
                token_array.append(token)
                
                // clear the stack -
                local_character_stack.removeAll(keepCapacity: true)
            }
            else if sentence_character == ")" {
                
                // ok, we have a ), but we could have an ID on the stack ...
                if (local_character_stack.count>0){
                    let identifier_check = isLegalIdentifier(local_character_stack)
                    if (identifier_check.isIdentifier == true) {
                        
                        if let lexeme_value = identifier_check.lexeme {
                            
                            // ok, we matched on induce -
                            let token = VLEMToken(token_type:TokenType.BIOLOGICAL_SYMBOL, line_number: lineNumber, column_number: column_index, lexeme:lexeme_value, value: nil)
                            token_array.append(token)
                            
                            // clear the stack -
                            local_character_stack.removeAll(keepCapacity: true)
                        }
                    }
                }
                
                // ok, we have a RPAREN - build the token, add to the array -
                let token = VLEMToken(token_type:TokenType.RPAREN, line_number: lineNumber, column_number: column_index, lexeme: ")", value: nil)
                token_array.append(token)
            }
            else if sentence_character == "," {
                
                // ok, we have a COMMA - build the token, add to the array -
                let token = VLEMToken(token_type:TokenType.COMMA, line_number: lineNumber, column_number: column_index, lexeme: ",", value: nil)
                token_array.append(token)
                
                // clear the stack -
                local_character_stack.removeAll(keepCapacity: true)
            }
            else if sentence_character == "|" {
                
                // ok, we have a VERT - build the token, add to the array -
                let token = VLEMToken(token_type:TokenType.VERT, line_number: lineNumber, column_number: column_index, lexeme: "|", value: nil)
                token_array.append(token)
                
                // clear the stack -
                local_character_stack.removeAll(keepCapacity: true)
            }
            else if sentence_character == "a" &&
                sentence[advance(sentence.startIndex, column_index+1)] == " " {
                
                // ok, we have a "a" - build the token, add to the array -
                let token = VLEMToken(token_type:TokenType.A, line_number: lineNumber, column_number: column_index, lexeme: "a", value: nil)
                token_array.append(token)
                    
                // clear the stack -
                local_character_stack.removeAll(keepCapacity: true)
            }
            else {
                
                // ok, so we don't have a single character token, but it is *not* a comment
                // However, we need to check to see if this is a whitespace char ..
                if (sentence_character == " "){
                    
                    // ok, we ran into whitespace ...
                    // if local_character_stack is elements, then we have captured a word ... need to check to see what it is ...
                    if (local_character_stack.count>0){
                        
                        // we got to do a bunch of tests to do here to determine what type of item we have.
                        if (isInduces(local_character_stack) == true){
                            
                        }
                        else if (isInduce(local_character_stack) == true){
                            
                            // ok, we matched on induce -
                            let token = VLEMToken(token_type:TokenType.INDUCE, line_number: lineNumber, column_number: column_index, lexeme: "induce", value: nil)
                            token_array.append(token)
                            
                            // clear the stack -
                            local_character_stack.removeAll(keepCapacity: true)
                        }
                        else if (isAnd(local_character_stack) == true) {
                            
                            // captutre and -
                            let token = VLEMToken(token_type:TokenType.AND, line_number: lineNumber, column_number: column_index, lexeme: "and", value: nil)
                            token_array.append(token)
                            
                            // clear the stack -
                            local_character_stack.removeAll(keepCapacity: true)
                        }
                        else if (isThe(local_character_stack) == true || isOf(local_character_stack) == true) {
                            
                            // we do *not* capture these ... 
                            // they have english significance, but not compiler significance
                            
                            // clear the stack -
                            local_character_stack.removeAll(keepCapacity: true)
                        }
                        else if (isTranscription(local_character_stack) == true) {
                            
                            // capture transcription -
                            let token = VLEMToken(token_type:TokenType.TRANSCRIPTION, line_number: lineNumber, column_number: column_index, lexeme: "transcription", value: nil)
                            token_array.append(token)
                            
                            // clear the stack -
                            local_character_stack.removeAll(keepCapacity: true)
                        }
                        else if (isGeneratesSymbol(local_character_stack) == true) {
                            
                            // capture transcription -
                            let token = VLEMToken(token_type:TokenType.GENERATES_SYMBOL, line_number: lineNumber, column_number: column_index, lexeme: "->", value: nil)
                            token_array.append(token)
                            
                            // clear the stack -
                            local_character_stack.removeAll(keepCapacity: true)
                        }
                        else {
                            
                            // ok, we don't match *any* of our keywords. This *could* be an identifier of some sort ..
                            // is this a legit name?
                            let identifier_check = isLegalIdentifier(local_character_stack)
                            if (identifier_check.isIdentifier == true) {
                                
                                if let lexeme_value = identifier_check.lexeme {
                                    
                                    // ok, we matched on induce -
                                    let token = VLEMToken(token_type:TokenType.BIOLOGICAL_SYMBOL, line_number: lineNumber, column_number: column_index, lexeme:lexeme_value, value: nil)
                                    token_array.append(token)
                                    
                                    // clear the stack -
                                    local_character_stack.removeAll(keepCapacity: true)
                                }
                            }
                            else {
                                
                                // oops -> we have appear to have a symbol with a problem  ...
                                var user_info_dictionary = Dictionary<String,String>()
                                if let lexeme_value = identifier_check.lexeme {
                                    
                                    // create the dictionary -
                                    user_info_dictionary["TOKEN"] = lexeme_value
                                }
                                
                                // ERROR: Notify the user that we are trying to tokenize an empty sentence ...
                                return (false,VLError(code: VLErrorCode.ILLEGAL_CHARACTER_ERROR, domain:"VLEMScanner", userInfo:user_info_dictionary))
                            }
                        }
                        
                        // clear the stack -
                        local_character_stack.removeAll(keepCapacity: true)
                    }
                }
                else {
                    
                    // we do *not* have a whitespace char -> so we are still processing non whitespace. Grab the char and put into the array -
                    local_character_stack.append(sentence_character)
                }
            }
            
            // update the colum index -
            column_index++
        }
        
        // ok, so if we get here *and* we have stack, then we need to process. We at the end of the sentence -
        if (local_character_stack.count>0){
            
            if (isSYSTEM(local_character_stack) == true){
                
                // capture transcription -
                let token = VLEMToken(token_type:TokenType.SYSTEM, line_number: lineNumber, column_number: column_index, lexeme: "SYSTEM", value: nil)
                token_array.append(token)
            }
            else {
                
                let identifier_check = isLegalIdentifier(local_character_stack)
                if (identifier_check.isIdentifier == true) {
                    
                    if let lexeme_value = identifier_check.lexeme {
                        
                        // ok, we matched on induce -
                        let token = VLEMToken(token_type:TokenType.BIOLOGICAL_SYMBOL, line_number: lineNumber, column_number: column_index, lexeme:lexeme_value, value: nil)
                        token_array.append(token)
                    }
                }
            }
            
            // clear the stack -
            local_character_stack.removeAll(keepCapacity: false)
        }
        
        // return -
        return (true,nil)
    }
    
    
    private func isInduces(characterStack:[Character]) -> Bool {
        
        // declaractions -
        var return_flag = false
        
        
        
        
        return return_flag
    }
    
    private func isGeneratesSymbol(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["-",">"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isSYSTEM(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["S","Y","S","T","E","M"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isOf(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["o","f"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isAnd(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["a","n","d"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isThe(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["t","h","e"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isInduce(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["i","n","d","u","c","e"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isRepresses(characterStack:[Character]) -> Bool {
    
        var match_array:[Character] = ["r","e","p","r","e","s","s","e","s"]
        return (matchLogic(characterStack, matchArray: match_array))
    }

    private func isRepress(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["r","e","p","r","e","s","s"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isRNAP(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["R","N","A","P"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isRIBOSOME(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["R","I","B","O","S","O","M","E"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isTranscription(characterStack:[Character]) -> Bool {
    
        var match_array:[Character] = ["t","r","a","n","s","c","r","i","p","t","i","o","n"]
        return (matchLogic(characterStack, matchArray: match_array))
    }

    private func isTranslation(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["t","r","a","n","s","l","a","t","i","o","n"]
        return (matchLogic(characterStack, matchArray: match_array))

    }
    
    private func isActivates(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["a","c","t","i","v","a","t","e","s"]
        return (matchLogic(characterStack, matchArray: match_array))
        
    }

    private func isActivate(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["a","c","t","i","v","a","t","e"]
        return (matchLogic(characterStack, matchArray: match_array))
        
    }
    
    private func isTransfer(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["t","r","a","n","s","f","e","r"]
        return (matchLogic(characterStack, matchArray: match_array))
        
    }
    
    private func isTransfered(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["t","r","a","n","s","f","e","r","e","d"]
        return (matchLogic(characterStack, matchArray: match_array))
        
    }

    private func isTo(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["t","o"]
        return (matchLogic(characterStack, matchArray: match_array))
        
    }
    
    private func isFrom(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["f","r","o","m"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isParameter(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["p","a","r","a","m","e","t","e","r"]
        return (matchLogic(characterStack, matchArray: match_array))
    }
    
    private func isIs(characterStack:[Character]) -> Bool {
        
        var match_array:[Character] = ["i","s"]
        return (matchLogic(characterStack, matchArray: match_array))
    }

    private func matchLogic(characterStack:[Character],matchArray:[Character]) -> Bool {
        
        // ok, so there are some easy tests to do first, e.g., they have to be the same length -
        if (characterStack.count != matchArray.count) {
            return false
        }
        
        // go thru the chars, until we do *not* match
        let number_of_chars = characterStack.count
        for var char_index = 0;char_index<number_of_chars;char_index++ {
            
            if (characterStack[char_index] != matchArray[char_index]){
                
                return false
            }
        }
        
        // default - true
        return true
    }
    
    private func isLegalIdentifier(characterStack:[Character]) -> (isIdentifier:Bool,lexeme:String?) {
        

        // create a string -
        var local_string = String()
        let number_of_chars = characterStack.count
        for var char_index = 0;char_index<number_of_chars;char_index++ {
            local_string = local_string+String(characterStack[char_index])
        }
        
        // ok, we have a string that we can do regex on -
        if local_string ~= /"^[A-Za-z_][A-Za-z0-9_].*" {
            
            // my string matches this pattern ...
            return (true,local_string)
        }
        
        return (false,local_string)
    }
}
