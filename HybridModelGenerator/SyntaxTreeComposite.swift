//
//  SyntaxTreeComposite.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

class SyntaxTreeComposite: SyntaxTreeComponent,SequenceType {
    
    // declarations -
    var children_array:[SyntaxTreeComponent] = [SyntaxTreeComponent]()

    func generate() -> AnyGenerator<SyntaxTreeComponent> {
        
        // keep the index of the next car in the iteration
        var nextIndex = children_array.count-1
        
        // Construct a GeneratorOf<Car> instance,
        // passing a closure that returns the next
        // car in the iteration
        return anyGenerator {
            
            if (nextIndex < 0) {
                return nil
            }
            
            return self.children_array[nextIndex--]
        }
    }
    
    // MARK: - Tree node access methods 
    func addNodeToTree(node:SyntaxTreeComponent) -> Void {
        
        // ok, we want to add this node to my children.
        // However, we want to be able to navigate "backwards" so a parent pointer -
        node.parent_pointer = self
        
        // add child to array -
        children_array.append(node)
    }
    
    func getChildAtIndex(index:Int) -> SyntaxTreeComponent? {
        
        // make sure we have this element ...
        if ((children_array.count - 1) < index){
            return nil
        }
        
        return children_array[index]
    }
    
    func numberOfChildren() -> Int {
        return children_array.count
    }
    
    deinit {
        print("Compsite deinit method called ...")
    }
    
    // override the accept method -
    override func accept(visitor:SyntaxTreeVisitor) -> Void {
        
        if (visitor.shouldVisit(self)){
         
            // visit me first ...
            
            // Call willVisit to do any prep work
            visitor.willVisit(self)
            
            // Visit -
            visitor.visit(self)
            
            // Call didVisit to finish up -
            visitor.didVisit(self)
            
            // Visit my children -
            for syntax_node in children_array {
                syntax_node.accept(visitor)
            }
        }
    }
}
