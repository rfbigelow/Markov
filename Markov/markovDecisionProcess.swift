//
//  markovDecisionProcess.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

struct Transition<State: Hashable>: Hashable {
    let state: State
    var reward: Reward
}

/// A type that models a Markov Decision Process (MDP).
protocol MarkovDecisionProcess {
    associatedtype Action: Hashable
    associatedtype State: Hashable
    
    /// Gets the states for this MDP.
    var states: Set<State> { get }
    
    /// Gets the actions that are available from the given state.
    func getActions(forState s: State) -> Set<Action>?
    
    /// Gets the reward value for taking action a from state s.
    func getReward(fromState s: State, forTakingAction a: Action) -> Reward
    
    /// Gets the reward value for taking action a and transitioning to state next.
    func getReward(fromState s: State, forTakingAction a: Action, transitioningTo next: State) -> Reward
    
    func getTransitions(fromState s: State, forTakingAction a: Action) -> [(Transition<State>, Double)]?
    
    func getTransitions(fromState s: State, forTakingAction a: Action, transitioningTo next: State) -> [(Transition<State>, Double)]?
    
    /// Performs a transition from the state s to a new state by taking action a.
    func transition(fromState s: State, byTakingAction a: Action) -> (State, Reward)
}
