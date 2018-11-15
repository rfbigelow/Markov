//
//  epsilonGreedyPolicy.swift
//  Markov
//
//  Created by Robert Bigelow on 11/14/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A policy that usually selects the best action, but sometimes selects a random action.
struct EpsilonGreedyPolicy<State: Hashable, Action: Hashable>: Policy {
    
    private let actionsForState: (State) -> Set<Action>?
    private let q: (State, Action) -> Reward
    
    let epsilon: Double
    
    /// Initializes an epsilon-greedy policy
    init(actionsForStateDelegate: @escaping (State) -> Set<Action>?,
         actionValueDelegate: @escaping (State, Action) -> Reward,
         epsilon: Double) {
        self.actionsForState = actionsForStateDelegate
        self.q = actionValueDelegate
        self.epsilon = epsilon
    }
    
    /// Gets the probability of taking action a from state s.
    func getProbability(fromState s: State, ofTaking a: Action) -> Double {
        guard let actions = actionsForState(s) else {
            return 0.0
        }
        
        let rand = Double.random(in: 0...1)
        if rand < epsilon {
            print("epsilon, my friend")
            return 1.0 / Double(actions.count)
        }
        
        if let maxQ = actions.map({ q(s, $0) }).max(), maxQ == q(s, a) {
            return 1.0
        }
        
        return 0.0
    }
    
    /// Gets an action to take from the state s according to this policy.
    func getAction(forState s: State) -> Action? {
        guard let actions = actionsForState(s) else {
            return nil
        }
        
        let rand = Double.random(in: 0...1)
        if rand < epsilon {
            print("epsilon, my friend")
            return actions.randomElement()
        }
        
        return actions.max(by: { q(s, $0) < q(s, $1) })
    }
}
