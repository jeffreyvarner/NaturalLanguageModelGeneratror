//
//  VLEMParserTest.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 5/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa
import XCTest

class VLEMParserTest: XCTestCase {

    // Declarations -
    let test_path = "/Users/jeffreyvarner/Desktop/HybridModelTest/Negative.net"
    var parser:VLEMParser?
    
    override func setUp() {
        super.setUp()
        
        // make the URL -
        let test_url = NSURL(fileURLWithPath: test_path)
        
        // build a scanner, use space as the delimiter -
        parser = VLEMParser(inputURL:test_url!)
    }
    
    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testParserParseFunction() -> Void {
        
        // execute the parse function -
        if let local_parser = parser {
            local_parser.parse()
        }
    }
}
