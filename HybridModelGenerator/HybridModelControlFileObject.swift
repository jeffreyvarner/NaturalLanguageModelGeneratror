//
//  HybridModelControlFileObject.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 4/23/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class HybridModelControlFileObject: NSObject {
    
    // Declarations -
    private var model_context:HybridModelContext
    private var strategy_object:CodeStrategy
    
    init(context:HybridModelContext,strategy:CodeStrategy){
        self.model_context = context
        self.strategy_object = strategy
    }
    
    // doExecute -
    func doExecute() -> String {
        
        // call the strategy object -
        let context = self.model_context
        let strategy = self.strategy_object
        
        // return -
        return strategy.execute(context)
    }
}
