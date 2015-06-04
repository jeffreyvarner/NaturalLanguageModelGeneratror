//
//  SyntaxTreeComposite.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class SyntaxTreeComposite: SyntaxTreeComponent {
    
    // declarations -
    var children_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()

    // MARK: - Tree node access methods 
    func addNodeToTree(node:SyntaxTreeComponent) -> Void {
        children_array.append(node)
    }
}
