//
//  randomSelectPolicy.swift
//  Markov
//
//  Created by Robert Bigelow on 11/11/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

struct RandomSelectPolicy<T: MarkovDecisionProcess>: Policy {
    typealias Action = T.Action
    typealias State = T.State

    private var actionsForState: Dictionary<State, Set<Action>> = Dictionary()
    
    init(mdp: T) {
        for state in mdp.states {
            if let actions = mdp.getActions(forState: state) {
                actionsForState[state] = actions
            }
        }
    }
    
    /// Gets the probability of taking action a from state s.
    func getProbability(fromState s: State, ofTaking a: Action) -> Double {
        if let actions = actionsForState[s], actions.contains(a) {
            return 1.0 / Double(actions.count)
        }
        else {
            return 0.0
        }
    }
    
    /// Gets an action to take from the state s according to this policy.
    func getAction(forState s: State) -> Action? {
        if let actions = actionsForState[s] {
            return actions.randomElement()
        }
        return nil
    }  
}
