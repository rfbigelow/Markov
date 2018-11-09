//
//  Environment.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// A type that provides an environment interface for reinforcement learning.
protocol Environment {
    associatedtype Action: Hashable
    associatedtype State
    
    var currentState: State { get }
    
    var availableActions: Set<Action>? { get }
    
    /// Selects the given action and performs it, causing the environment to produce a reward and a new state.
    mutating func select(action: Action) -> (Reward, State)
}
