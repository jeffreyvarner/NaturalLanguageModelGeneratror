//
//  HybridStateModel.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/25/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class HybridStateModel: NSObject {
    
    // Declations -
    var state_symbol_string:String
    var default_value:Double?
    var state_role:RoleDescriptor?
    var state_type:TypeDescriptor?
    
    init(symbol:String){
        
        // capture the state symbol -
        self.state_symbol_string = symbol
    }

    
    
}
