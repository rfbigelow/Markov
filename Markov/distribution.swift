//
//  distribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A type representing a distribution of a random variable.
protocol Distribution {
    associatedtype T
    
    /// Gets the expected value by transforming each event into a Double representing the event's value.
    func getExpectedValue(withTransform t: (T) -> Double) -> Double
    
    /// Gets the next event in the distribution.
    func getNext() throws -> T
    
    /// Gets the probability of the event e occurring.
    func getProbability(forEventMatchedBy isMatch:(T) -> Bool) -> Double
    
    /// Gets the event matching the given predicate, if a match is found.
    func getEvent(matching isMatch:(T) -> Bool) -> T?
}
