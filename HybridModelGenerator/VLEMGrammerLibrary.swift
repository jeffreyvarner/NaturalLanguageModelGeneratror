//
//  VLEMGrammerLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/29/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class VLEMGrammerLibrary: NSObject {

    // methods
    static func mustBeTokenOfType(token:VLEMToken,tokenType:TokenType) -> Bool {
    
        if (token.token_type == tokenType){
            return true
        }
        else {
            return false
        }
    }
}

class InduceStatementStrategy:GrammerStrategy {

    // Top level method
    func parse(scanner:VLEMScanner) -> VLError? {
    
        // ok, if this method gets called, then we have a token stream that we
        // think involves gene expression
        
        // do we have any tokens?
        if (scanner.hasMoreTokens() == false){
            return VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain: "VLEMGrammarLibrary", userInfo: nil)
        }
     
        // get the first token and go ...
        if let first_token = scanner.getNextToken() {
            
            // ok, what type of token is this?
            // For this type of statement, we would expect a LPAREN or a SYMBOL
            if (first_token.token_type == TokenType.LPAREN){
                
                // We could have a protein list ...
                return parseProteinList(scanner)
            }
            else if (first_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                
                // We could have a single protein -
                return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = first_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(first_token.line_number) col: \(first_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected either \"(\" or a biological symbol, found \"\(first_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parse"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // create user dictionary -
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parse"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    // MARK: - Grammer specific methods for Induce statement
    func parseProteinList(scanner:VLEMScanner) -> VLError? {
        
        // Get the next token -
        if var next_token = scanner.getNextToken() {
        
            if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected a biological symbol, found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseProteinList"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseProteinList"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseProteinSymbol(scanner:VLEMScanner) -> VLError? {
        
        if var next_token = scanner.getNextToken() where (scanner.hasMoreTokens() == true) {
            
            if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.RPAREN)){
                return parseRParenToken(scanner)
            }
            else if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.AND)){
                return parseAndToken(scanner)
            }
            else if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCE)  ||
                    VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCES) ||
                    VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESSES) ||
                    VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESS)){
                    
                    // parse the action verb token -
                    return parseInducesToken(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected a \")\", \"and\" or an action \"induce\", \"induces\", \"represses\" or \"repress\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseProteinSymbol"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        else if (scanner.hasMoreTokens() == false) {
                
            // we could be done .. we'll often end on a symbol
            return nil
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseProteinSymbol"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseRParenToken(scanner:VLEMScanner) -> VLError? {
    
        // ok, the next token should be an INDUCE or INDUCES token -
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCE)  ||
                VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCES) ||
                VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESSES) ||
                VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESS)){
                    
                return parseInducesToken(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected action \"induce\", \"induces\",\"repress\" or \"represses\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseRParenToken"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseRParenToken"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseAndToken(scanner:VLEMScanner) -> VLError? {
    
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected a biological symbol, found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseAndToken"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseAndToken"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseInducesToken(scanner:VLEMScanner) -> VLError? {
        
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.TRANSCRIPTION) ||
                VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.EXPRESSION)){
                    
                    return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected \"transcription\" or \"expression\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseInducesToken"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseInducesToken"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseTranscriptionToken(scanner:VLEMScanner) -> VLError? {
        
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.TRANSCRIPTION) ||
                VLEMGrammerLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.EXPRESSION)){
                    
                    // ok, we have *only* one allowed target
                    return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected \"transcription\" or \"expression\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseTranscriptionToken"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseTranscriptionToken"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
}

