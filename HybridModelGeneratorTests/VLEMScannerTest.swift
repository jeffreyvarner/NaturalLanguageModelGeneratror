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
    let test_sentence = "protein_N1 and protein_N2 induce the transcription of gene_N3 -> mRNA_N3"
    var scanner:VLEMScanner?
    
    override func setUp() {
        super.setUp()
        
        // build a scanner, use space as the delimiter -
        scanner = VLEMScanner(sentenceDelimiter: " ")
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testScannerScanFunction() -> Void {
        
        // scan -
        if let local_scanner = scanner {
            
            let return_data = local_scanner.scanSentence(test_sentence)
            if (return_data.success == true){
                
                local_scanner.printSentenceTokens()
                XCTAssert(true, "Scanner initialization and scanning succeded")
            }
            else {
                // ok, we have an error ...
                if let error_data = return_data.error {
                    
                    let error_code = error_data.code
                    switch (error_code) {
                        case .ILLEGAL_CHARACTER_ERROR:
                            
                            // get the user dictionary from the error -
                            if let bad_token = error_data.userInfo["OFFENDING_TOKEN"] {
                                println("Illegal character found in token => \(bad_token)")
                            }
                            else {
                            
                                println("Illegal character found in token. No token returned ...")
                                //XCTAssert(false, "Scanner initialization or scanning failed")
                            }
                        
                        
                        default:
                            println("Some other error found ...")
                            XCTAssert(false, "Scanner initialization or scanning failed")
                    }
                }
            }
        }
        else {
            
            XCTAssert(false, "Scanner initialization or scanning failed")
            
        }
    }
    
    func testGetNextScannerTokenFunction() -> Void {
        
        // scan -
        if let local_scanner = scanner {
            
            while (local_scanner.hasMoreSentenceTokens()){
                
                // get the token -
                if let local_token = local_scanner.getNextSentenceToken() {
                    
                    println("NEXT TOKEN: \(local_token)")
                    XCTAssert(true, "Scanner initialization and scanning succeded. TOKEN:\(local_token)")
                }
                else {
                    XCTAssert(false, "Missing token?")
                }
            }
        }
        else {
            
            XCTAssert(false, "Scanner initialization or scanning failed")
            
        }
    }
}
