//
//  policy.swift
//  Markov
//
//  Created by Robert Bigelow on 11/9/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// A policy gives the probability of taking an action from a state.
protocol Policy {
    associatedtype State: Hashable
    associatedtype Action
    
    /// Gets the probability of taking action a from state s.
    func getProbability(fromState s: State, ofTaking a: Action) -> Double
}
