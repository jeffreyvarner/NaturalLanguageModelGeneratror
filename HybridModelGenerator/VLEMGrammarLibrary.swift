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
    
    static func missingTokenErrorFactory(className className:String,methodName:String) -> VLError {
    
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.MISSION_TOKEN_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    
    static func missingSemicolonSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a \";\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }

    static func missingKeywordSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a keyword, found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingRegulatoryKeywordSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a regulatory keyword, found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }

    
    static func missingGeneratesSymbolSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected the \"->\" or \"<->\" symbol, found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingBiologicalSymbolSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a biological symbol, found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingIsOrAreTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected an \"is\" or \"are\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingATokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a \"a\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingAndTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a \"and\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingOrTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a \"or\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }

    static func missingByTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a \"by\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }


    static func missingTypeTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected a \"type\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }

    static func missingReservedTypeKeywordTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Type assignment: expected \"PROTEIN\", \"DNA\", \"MESSENGER_RNA\" or \"REGULATORY_RNA\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingTransferTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String) -> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected \"transfer\" or \"transferred\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func incompleteSentenceSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String)-> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected either \"(...)\" or a biological symbol, found \"\(token.lexeme!)\". Do you have an extra or missing \"(\" or \")\" -or- a list without enclosing (...)?"
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingToOrFromTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String)-> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Expected either \"from\" or \"to\", found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
    
    static func missingOrMismatchedParenthesisTokenSyntaxErrorFactory(token token:VLEMToken,className:String,methodName:String)-> VLError {
        
        var error_information_dictionary = Dictionary<String,String>()
        error_information_dictionary["TOKEN"] = token.lexeme
        error_information_dictionary["LOCATION"] = "Line: \(token.line_number) col: \(token.column_number)"
        error_information_dictionary["MESSAGE"] = "Mismatched parenthesis? Check for extra or missing ) -or- a list without enclosing (...), found \"\(token.lexeme!)\"."
        error_information_dictionary["METHOD"] = methodName
        error_information_dictionary["CLASS"] = className
        return VLError(code: VLErrorCode.INCOMPLETE_SENTENCE_SYNTAX_ERROR, domain: "VLEMGrammarLibrary", userInfo: error_information_dictionary)
    }
}

// MARK: - Grammer specific class for metabolic stoichiometry reactions 
class MetabolicStoichiometryStatementGrammarStrategy:GrammarStrategy {
    
    // Top level method
    func parse(scanner:VLEMScanner) -> VLError? {
        
        // do we have any tokens?
        if (scanner.hasMoreTokens() == false){
            return VLError(code: VLErrorCode.EMPTY_SENTENCE_ERROR, domain: "VLEMGrammarLibrary", userInfo: nil)
        }
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.LPAREN)){
                
                // ok, we have the a left paren -
                if let _symbol_token = scanner.getNextToken() {
                    if (VLEMGrammarLibrary.mustBeTokenOfType(_symbol_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                        
                        return parseBiologicalSymbolToken(scanner)
                    }
                }
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseBiologicalSymbolToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.PLUS)){
                
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.GENERATES_SYMBOL) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.REVERSIBLE_GENERATES_SYMBOL)) {
                    
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.IS)){
                return parseCatalyzedToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.SEMICOLON)){
                return nil
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                
                if (scanner.peekAtNextTokenType() == TokenType.CATALYZES ||
                    scanner.peekAtNextTokenType() == TokenType.CATALYZE ||
                    scanner.peekAtNextTokenType() == TokenType.CATALYZED){
                    
                    // ok, we have an alternative catalyze statement -
                    // call catalyze -
                    return parseCatalyzedToken(scanner)
                }
                else {
                    return parseBiologicalSymbolToken(scanner)
                }
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.LPAREN)){
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.RPAREN)){
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.OR)){
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.CATALYZES) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.CATALYZE) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.CATALYZED)) {
                
                if (scanner.peekAtNextTokenType() == TokenType.BIOLOGICAL_SYMBOL || scanner.peekAtNextTokenType() == TokenType.LPAREN){
                    return parseBiologicalSymbolToken(scanner)
                }
                else {
                    return VLEMGrammarLibrary.missingBiologicalSymbolSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
                }
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
    
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseOrToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.OR)){
                
                return parseBiologicalSymbolToken(scanner)
                
            }
            else {
                return VLEMGrammarLibrary.missingOrTokenSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseGenerateToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.GENERATES_SYMBOL) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.REVERSIBLE_GENERATES_SYMBOL)){
                    
                return parseBiologicalSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingGeneratesSymbolSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
    
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseCatalyzedToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
        
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.CATALYZES) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.CATALYZE) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.CATALYZED)){
                
                if (scanner.peekAtNextTokenType() == TokenType.BIOLOGICAL_SYMBOL || scanner.peekAtNextTokenType() == TokenType.LPAREN){
                 
                    return parseBiologicalSymbolToken(scanner)
                    
                }
                else {
                    return parseByToken(scanner)
                }
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
    
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }

    func parseByToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BY)){
                
                return parseBiologicalSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingByTokenSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
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
                error_information_dictionary["MESSAGE"] = "Type assignment: expected a biological symbol, found \"\(first_token.lexeme!)\"."
                error_information_dictionary["METHOD"] = "\(__FUNCTION__)"
                error_information_dictionary["CLASS"] = String(self)
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
            
                return VLEMGrammarLibrary.missingIsOrAreTokenSyntaxErrorFactory(token: next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return false
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseASymbol(scanner:VLEMScanner) -> VLError? {
        
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.A)){
                return parseTypeSymbol(scanner)
            }
            else {
                
                // return false
                return VLEMGrammarLibrary.missingATokenSyntaxErrorFactory(token: next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return false
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseTypeSymbol(scanner:VLEMScanner) -> VLError? {
        
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.TYPE)){
                return parseReservedSpeciesTypeSymbol(scanner)
            }
            else {
                
                // return false
                return VLEMGrammarLibrary.missingTypeTokenSyntaxErrorFactory(token: next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return false
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseReservedSpeciesTypeSymbol(scanner:VLEMScanner) -> VLError? {
        
        if let next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.PROTEIN) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.METABOLITE) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.DNA) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.MESSENGER_RNA) ||
                VLEMGrammarLibrary.mustBeTokenOfType(next_token, tokenType: TokenType.REGULATORY_RNA)){
                
                // ok, we reached the bottom of the statement -
                return parseSemicolonToken(scanner)
            }
            else {
                
                // return false
                return VLEMGrammarLibrary.missingReservedTypeKeywordTokenSyntaxErrorFactory(token: next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return false
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseSemicolonToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.SEMICOLON)){
                return nil
            }
            else {
                return VLEMGrammarLibrary.missingSemicolonSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
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
                return parseBiologicalSymbolToken(scanner)
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
    
    func parseBiologicalSymbolToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            // ok, we have a biological symbol -
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.IS)){
                return parseTransferredSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.AND)) {
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                return parseAndToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.RPAREN)){
                return parseRParenToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingBiologicalSymbolSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }

    
    func parseAndToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            // ok, we think we have a symbol (AND|OR) symbol ...) statement. _next_token could be a biological symbol
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.AND) == true){
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.RPAREN)){
                return parseRParenToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingAndTokenSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
       return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseRParenToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.IS) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.ARE)){
                return parseTransferredSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingIsOrAreTokenSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseIsToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.TRANSFER) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.TRANSFERRED)){
                
                return parseTransferredSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseTransferredSymbolToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.TRANSFERRED) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.TRANSFER)){
                    
                    // we should now have a direction -
                    return parseSystemTransferDirectionToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingTransferTokenSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }

    func parseSystemTransferDirectionToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.TO) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.FROM)){
                    
                // we should now have system -
                return parseSystemSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingToOrFromTokenSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseSystemSymbolToken(scanner:VLEMScanner) -> VLError? {
        
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.SYSTEM)){
                
                // this is the end - we should have a ;
                return parseSemicolonToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }

    func parseSemicolonToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.SEMICOLON)){
                return nil
            }
            else {
                return VLEMGrammarLibrary.missingSemicolonSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
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
     
        // get the first token and go ...
        if let first_token = scanner.getNextToken() {
            
            // ok, what type of token is this?
            // For this type of statement, we would expect a LPAREN or a SYMBOL
            if (first_token.token_type == TokenType.LPAREN){
                
                // check ahead .. do we have a closing )?
                if scanner.isMatchingRightParenthesisOnTokenStack() == true {
                    
                    // We could have a protein list ...
                    return parseBiologicalSymbolToken(scanner)
                }
                else {
                    return VLEMGrammarLibrary.missingOrMismatchedParenthesisTokenSyntaxErrorFactory(token: first_token, className: String(self), methodName: __FUNCTION__)
                }
            }
            else if (first_token.token_type == TokenType.BIOLOGICAL_SYMBOL &&
                scanner.peekAtNextTokenType() != TokenType.RPAREN &&
                scanner.peekAtNextTokenType() != TokenType.AND &&
                scanner.peekAtNextTokenType() != TokenType.OR){
                
                // We could have a single protein -
                return parseBiologicalSymbolToken(scanner)
            }
            else {
                
                return VLEMGrammarLibrary.missingBiologicalSymbolSyntaxErrorFactory(token: first_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return missing token -
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseBiologicalSymbolToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.INDUCE)  ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.INDUCES) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.REPRESS) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.REPRESSES)){
                
                return parseExpressionOrTranscriptionToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                return parseOrAndToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.RPAREN)){
                return parseBiologicalRegulatoryActionToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.LPAREN)){
                return parseBiologicalSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
    
        // return missing token -
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseBiologicalRegulatoryActionToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.INDUCE)  ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.INDUCES) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.REPRESS) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.REPRESSES)){
                    
                return parseExpressionOrTranscriptionToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.SEMICOLON)){
                return nil
            }
            else {
                return VLEMGrammarLibrary.missingRegulatoryKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return missing token -
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }

    
    func parseExpressionOrTranscriptionToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.EXPRESSION) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.TRANSCRIPTION)){
                
                return parseBiologicalSymbolToken(scanner)
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
    
        // return missing token -
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
    
    func parseOrAndToken(scanner:VLEMScanner) -> VLError? {
    
        if let _next_token = scanner.getNextToken() {
            
            if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.BIOLOGICAL_SYMBOL)){
                
                return parseBiologicalSymbolToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.AND) ||
                VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.OR)){
                
                // I need to check - do we have a biological symbol?
                if (scanner.peekAtNextTokenType() == TokenType.BIOLOGICAL_SYMBOL){
                    return parseBiologicalSymbolToken(scanner)
                }
                else {
                 
                    // we have a missing symbol?
                    return VLEMGrammarLibrary.missingBiologicalSymbolSyntaxErrorFactory(token: scanner.getNextToken()!, className: String(self), methodName: __FUNCTION__)
                }
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.RPAREN)){
                return parseBiologicalRegulatoryActionToken(scanner)
            }
            else if (VLEMGrammarLibrary.mustBeTokenOfType(_next_token, tokenType: TokenType.SEMICOLON)){
                return nil
            }
            else {
                return VLEMGrammarLibrary.missingKeywordSyntaxErrorFactory(token: _next_token, className: String(self), methodName: __FUNCTION__)
            }
        }
        
        // return missing token -
        return VLEMGrammarLibrary.missingTokenErrorFactory(className: String(self), methodName: __FUNCTION__)
    }
}

