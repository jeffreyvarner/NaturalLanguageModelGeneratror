//
//  Model.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/2/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa

protocol Composite {

}

class Model: Composite {

    // declarations -
    private var children_array:[Sentence] = [Sentence]()
    
    // MARK: - Methods to add, delelete or get children
    func addSentenceToModel(sentenceObject:Sentence) -> Void {
        children_array.append(sentenceObject)
    }
    
    func removeAllSentences() -> Void {
        children_array.removeAll(keepCapacity: true)
    }
    
    func getNumberOfSentences() -> Int {
        return count(children_array)
    }
    
    func removeSentenceAtIndex(index:Int) -> Void {
        
        if (index<=children_array.count - 1){
            children_array.removeAtIndex(index)
        }
    }
    
    func getSentenceAtIndex(index:Int) -> Sentence? {
        
        if (index<=children_array.count - 1){
            return children_array[index]
        }
        
        return nil
    }
}
