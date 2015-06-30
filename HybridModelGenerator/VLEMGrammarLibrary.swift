//
//  VLEMGrammarLibrary.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/29/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class VLEMGrammarLibrary: NSObject {

    // methods
    static func mustBeTokenOfType(token:VLEMToken,tokenType:TokenType) -> Bool {
    
        if (token.token_type == tokenType){
            return true
        }
        else {
            return false
        }
    }
    
    static func missingTokenErrorFactory(#className:String,methodName:String) -> VLError {
    
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func incompleteSentenceSyntaxErrorFactory(#token:VLEMToken,className:String,methodName:String)-> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected either \"(...)\" or a biological symbol, found \"\(token.lexeme!)\". Do you have an extra or missing \"(\" or \")\" -or- a list without enclosing (...)?"
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
}

// MARK: - Grammer specific class for type assignments
class TypeAssignmentStatementGrammarStrategy:GrammarStrategy {
    
    // Top level method
    func parse(scanner:VLEMScanner) -> VLError? {
        
        // ok, this involves checking a statment of the form:
        // <prefix> is a type of {biological type}
        
        // do we have any tokens?
        if (scanner.hasMoreTokens() == false){
            return VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain: "VLEMGrammarLibrary", userInfo: nil)
        }
        
        // get the first token and go ...
        if let first_token = scanner.getNextToken() {
            
            if (first_token.token_type == TokenType.BIOLOGICAL_SYMBOL){
                return parsePrefixSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = first_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(first_token.line_number) col: \(first_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Type assignment: expected a biological symbol, found \"\(first_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parse"
                error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // create user dictionary -
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parse"
        error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parsePrefixSymbol(scanner:VLEMScanner) -> VLError? {
    
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.IS)){
                return parseASymbol(scanner)
            }
            else {
            
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Type assignment: expected is, found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parsePrefixSymbol"
                error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parsePrefixSymbol"
        error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseASymbol(scanner:VLEMScanner) -> VLError? {
        
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.A)){
                return parseTypeSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Type assignment: expected \"a\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseASymbol"
                error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseASymbol"
        error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseTypeSymbol(scanner:VLEMScanner) -> VLError? {
        
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.TYPE)){
                return parseReservedSpeciesTypeSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Type assignment: expected \"type\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseTypeSymbol"
                error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseTypeSymbol"
        error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseReservedSpeciesTypeSymbol(scanner:VLEMScanner) -> VLError? {
        
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.PROTEIN) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.METABOLITE) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.DNA) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.MESSENGER_RNA) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REGULATORY_RNA)){
                
                    // ok, we reached the bottom of the statement -
                    return nil
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Type assignment: expected \"PROTEIN\", \"DNA\", \"MESSENGER_RNA\" or \"REGULATORY_RNA\", found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseReservedSpeciesTypeSymbol"
                error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseReservedSpeciesTypeSymbol"
        error_information_dictionary["CLASS"] = "TypeAssignmentStatementGrammarStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }

}

// MARK: - Grammer specific class for System transfer statements
class SystemTransferStatementGrammarStrategy:GrammarStrategy {

    // Top level method
    func parse(scanner:VLEMScanner) -> VLError? {
    
        
        // do we have any tokens?
        if (scanner.hasMoreTokens() == false){
            return VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain: "VLEMGrammarLibrary", userInfo: nil)
        }
        
        
        
        // get the first token and go ...
        if let _first_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_first_token, tokenType: TokenType.LPAREN) == true &&
                scanner.isMatchingRightParenthesisOnTokenStack() == true){
                
                // ok, we have a (...) statement -
                return parseBiologicalSymbolList(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_first_token, tokenType: TokenType.BIOLOGICAL_SYMBOL) == true &&
                scanner.peekAtNextTokenType() != TokenType.RPAREN &&
                scanner.peekAtNextTokenType() != TokenType.AND &&
                scanner.peekAtNextTokenType() != TokenType.OR){
                    
                // we just have a biological symbol -
                return parseBiologicalSymbolToken(scanner)
            }
            else {
                
                // ok, so we don't have a ( not do we have a biological symbol ... syntax error
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = _first_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(_first_token.line_number) col: \(_first_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected either \"(...)\" or a biological symbol, found \"\(_first_token.lexeme!)\". Do you have an extra or missing \"(\" or \")\" -or- a list without enclosing (...)?"
                error_information_dictionary["METHOD"] = "parse"
                error_information_dictionary["CLASS"] = "\(self)"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // create user dictionary -
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parse"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseBiologicalSymbolList(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            // ok, we think we have a symbol (AND|OR) symbol ...) statement. _next_token could be a biological symbol
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL) == true && scanner.peekAtNextTokenType() == TokenType.AND){
                return parseAndToken(scanner)
            }
            else {
                
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = _next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(_next_token.line_number) col: \(_next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected \"and\", found \"\(_next_token.lexeme!)\"."
                error_information_dictionary["METHOD"] = "\(__FUNCTION__)"
                error_information_dictionary["CLASS"] = "\(self)"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "\(__FUNCTION__)"
        error_information_dictionary["CLASS"] = "\(self)"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseAndToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            // ok, we think we have a symbol (AND|OR) symbol ...) statement. _next_token could be a biological symbol
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL) == true){
                
            }
            else {
                
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = _next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(_next_token.line_number) col: \(_next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected a biological symbol, found \"\(_next_token.lexeme!)\"."
                error_information_dictionary["METHOD"] = "\(__FUNCTION__)"
                error_information_dictionary["CLASS"] = "\(self)"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        // return false
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "\(__FUNCTION__)"
        error_information_dictionary["CLASS"] = "\(self)"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    func parseBiologicalSymbolToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
        
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: toString(self), methodName: __FUNCTION__)
    }
}

// MARK: - Grammer specific class for Induce statement
class ExpressionStatementGrammarStrategy:GrammarStrategy {
    
    // Top level method
    func parse(scanner:VLEMScanner) -> VLError? {
    
        // ok, if this method gets called, then we have a token stream that we
        // think involves gene expression
        
        // do we have any tokens?
        if (scanner.hasMoreTokens() == false){
            return VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain: "VLEMGrammarLibrary", userInfo: nil)
        }
     
        // check for balanced parentheses in this statement -
        if (scanner.doesStatementContainParenthesisMismatch() == true){
            
            let first_token = scanner.getNextToken()
            var error_information_dictionary = Dictionary<String,String>()
            error_information_dictionary["TOKEN"] = first_token!.lexeme
            error_information_dictionary["LOCATION"] = "Line: \(first_token!.line_number) col: \(first_token!.column_number)"
            error_information_dictionary["MESSAGE"] = "Mismatched parenthesis? Check for extra or missing ) -or- a list without enclosing (...)."
            error_information_dictionary["METHOD"] = "parse"
            error_information_dictionary["CLASS"] = "InduceStatementStrategy"
            return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
        }
        
        // get the first token and go ...
        if let first_token = scanner.getNextToken() {
            
            // ok, what type of token is this?
            // For this type of statement, we would expect a LPAREN or a SYMBOL
            if (first_token.token_type == TokenType.LPAREN){
                
                // check ahead .. do we have a closing )?
                if scanner.isMatchingRightParenthesisOnTokenStack() == true {
                    
                    // We could have a protein list ...
                    return parseProteinList(scanner)
                }
                else {
                    
                    // return mismatch () error
                    var error_information_dictionary = Dictionary<String,String>()
                    error_information_dictionary["TOKEN"] = first_token.lexeme
                    error_information_dictionary["LOCATION"] = "Line: \(first_token.line_number) col: \(first_token.column_number)"
                    error_information_dictionary["MESSAGE"] = "Mismatched parenthesis? Check for extra or missing ) -or- a list without enclosing (...)."
                    error_information_dictionary["METHOD"] = "parse"
                    error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                    return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
                }
            }
            else if (first_token.token_type == TokenType.BIOLOGICAL_SYMBOL &&
                scanner.peekAtNextTokenType() != TokenType.RPAREN &&
                scanner.peekAtNextTokenType() != TokenType.AND &&
                scanner.peekAtNextTokenType() != TokenType.OR){
                
                // We could have a single protein -
                return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = first_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(first_token.line_number) col: \(first_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected either \"(\" or a biological symbol, found \"\(first_token.lexeme!)\" instead. Check for extra ) -or- a list without enclosing (...)?"
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
    
    func parseProteinList(scanner:VLEMScanner) -> VLError? {
        
        // Get the next token -
        if var next_token = scanner.getNextToken() {
        
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
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
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.RPAREN)){
                return parseRParenToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.AND)){
                return parseAndToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.OR)) {
                return parseOrToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCE)  ||
                    VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCES) ||
                    VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESSES) ||
                    VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESS)){
                    
                    // parse the action verb token -
                    return parseBiologicalActionToken(scanner)
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
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCE)  ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.INDUCES) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESSES) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REPRESS)){
                    
                return parseBiologicalActionToken(scanner)
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
    
    func parseOrToken(scanner:VLEMScanner) -> VLError? {
        
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                return parseProteinSymbol(scanner)
            }
            else {
                
                // return false
                var error_information_dictionary = Dictionary<String,String>()
                error_information_dictionary["TOKEN"] = next_token.lexeme
                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                error_information_dictionary["MESSAGE"] = "Expected a biological symbol, found \"\(next_token.lexeme!)\" instead."
                error_information_dictionary["METHOD"] = "parseOrToken"
                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
            }
        }
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = "parseOrToken"
        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }

    
    func parseAndToken(scanner:VLEMScanner) -> VLError? {
    
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
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
    
    func parseBiologicalActionToken(scanner:VLEMScanner) -> VLError? {
        
        if var next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.TRANSCRIPTION) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.EXPRESSION)){
                    
                    // ok, so we *may* have another list here.
                    // Peek one token ahead ...
                    if (scanner.peekAtNextTokenType() == TokenType.LPAREN){
                        
                        if let local_next_token = scanner.getNextToken() {
                            if (VLEMGrammarLibrary.mustBeTokenOfType(local_next_token, tokenType: TokenType.LPAREN) &&
                                scanner.isMatchingRightParenthesisOnTokenStack() == true){
                                
                                    return parseProteinList(scanner)
                            }
                            else {
                                
                                // return false
                                var error_information_dictionary = Dictionary<String,String>()
                                error_information_dictionary["TOKEN"] = next_token.lexeme
                                error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(local_next_token.column_number)"
                                error_information_dictionary["MESSAGE"] = "Expected a \"(\" with a matching \")\", found only \"\(local_next_token.lexeme!)\". Check for missing or mismatch parentheses."
                                error_information_dictionary["METHOD"] = "parseInducesToken"
                                error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                                return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
                            }
                        }
                    }
                    else if (scanner.peekAtNextTokenType() == TokenType.BIOLOGICAL_SYMBOL) {
                       return parseProteinSymbol(scanner)
                    }
                    else {
                    
                        // return false
                        var error_information_dictionary = Dictionary<String,String>()
                        error_information_dictionary["TOKEN"] = next_token.lexeme
                        error_information_dictionary["LOCATION"] = "Line: \(next_token.line_number) col: \(next_token.column_number)"
                        error_information_dictionary["MESSAGE"] = "Expected biological symbol list, found \"\(next_token.lexeme!)\" instead. Check for missing or mismatch parentheses."
                        error_information_dictionary["METHOD"] = "parseInducesToken"
                        error_information_dictionary["CLASS"] = "InduceStatementStrategy"
                        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
                    }
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
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.TRANSCRIPTION) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.EXPRESSION)){
                    
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

