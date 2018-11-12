//
//  policy.swift
//  Markov
//
//  Created by Robert Bigelow on 11/9/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A policy determines a course of action.
protocol Policy {
    associatedtype State: Hashable
    associatedtype Action
    
    /// Gets the probability of taking action a from state s.
    func getProbability(fromState s: State, ofTaking a: Action) -> Double
    
    /// Gets an action to take from the state s according to this policy.
    func getAction(forState s: State) -> Action?
}
