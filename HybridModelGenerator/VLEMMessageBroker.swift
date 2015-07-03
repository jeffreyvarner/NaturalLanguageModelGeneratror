//
//  VLEMMessageBroker.swift
//  HybridModelGenerator
//
//  Created by Jeffrey Varner on 6/21/15.
//  Copyright (c) 2015 Pooksoft. All rights reserved.
//

import Cocoa


private let _messageBroker = VLEMMessageBroker()

// Protocols
protocol Message    {
    
    func messageKey() -> MessageKey
    func messagePayload() -> Any?
}

protocol Subscriber {
    func receive(message message: Message) -> Void
}


class VLEMMessageBroker: NSObject {

    // Declarations -
    private var _subscriber_dictionary = Dictionary<MessageKey, Array<Subscriber>>()
    
    // no init -
    private override init() {
        print("Is this getting called?")
    }
    
    // Inner class for a singleton ... how does this work?
    class var sharedMessageBroker : VLEMMessageBroker
    {
        return _messageBroker
    }
    
    func subscribe(subscriber: Subscriber, messageKey: MessageKey)
    {
        if var _subscriber_array = _subscriber_dictionary[messageKey] {
            
            // add a new subscriber -
            _subscriber_array.append(subscriber)
            
            // reset -
            _subscriber_dictionary[messageKey] = _subscriber_array
        }
        else {
            
            // ok, we have *not yet* seen this key -
            _subscriber_dictionary[messageKey] = [subscriber]
        }
    }
    
    func publish(message message: Message)
    {
        if let _subscriber_array = _subscriber_dictionary[message.messageKey()]
        {
            for subscriber in _subscriber_array
            {
                subscriber.receive(message: message)
            }
        }
    }
}
