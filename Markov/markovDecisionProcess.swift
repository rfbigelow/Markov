//
//  markovDecisionProcess.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// A type that models a Markov Decision Process (MDP).
protocol MarkovDecisionProcess {
    associatedtype Action: Hashable
    associatedtype State: Hashable
    
    /// Gets the actions that are available from the given state.
    func getActions(forState state: State) -> Set<Action>?
    
    /// Gets the reward value for the given state.
    func getReward(forState state: State) -> Reward
    
    /// Performs a transition from the given state to a new state by doing the specified action.
    func transition(_ state: State, _ action: Action) -> State
}
