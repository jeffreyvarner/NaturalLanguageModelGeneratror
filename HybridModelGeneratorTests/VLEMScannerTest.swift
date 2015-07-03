//
//  VLEMScannerTest.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/20/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa
import XCTest
import HybridModelGenerator

class VLEMScannerTest: XCTestCase {

    // Declarations -
    let test_sentence = "(protein_N1 and protein_N2) induce the transcription of gene_N3 -> mRNA_N3"
    var scanner:VLEMScanner?
    
    override func setUp() {
        super.setUp()
        
        // build a scanner, use test sentence -
        let sentence_wrapper = VLEMSentenceWrapper(sentence: test_sentence, lineNumber: 0)
        scanner = VLEMScanner(sentenceWrapper: sentence_wrapper)
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testScannerScanFunction() -> Void {
        
        if let local_scanner = scanner {
            
            let scanner_result = local_scanner.scanSentence()
            
            if (scanner_result.success) {
                
                print("Sentence: \(test_sentence) was tokenized correctly")
                
            }
            else {
                
                print("Sentence: \(test_sentence) was NOT tokenized correctly")
            }
        }
    }
    
    func testGetNextTokenFunction() -> Void {
    
        if let local_scanner = scanner {
        
            let scanner_result = local_scanner.scanSentence()
            
            if (scanner_result.success) {
                
                print("Sentence: \(test_sentence) was tokenized correctly! Looking at tokens ..")
                
                while (local_scanner.hasMoreTokens()){
                    
                    // get the next token -
                    let token = local_scanner.getNextToken()
                    
                    if let _ = token, let local_lexeme = token?.lexeme {
                        
                        // print the lexeme -
                        print("TOKEN_VALUE = \(local_lexeme)")
                    }
                }
            }
            else {
                
                print("Sentence: \(test_sentence) was NOT tokenized correctly")
                return
            }
        }
    }
}
