//
//  mdpEnvironment.swift
//  Markov
//
//  Created by Robert Bigelow on 11/9/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// An environment provided by a Markov decision process
struct MdpEnvironment<T: MarkovDecisionProcess>: Environment {
    typealias Action = T.Action
    typealias State = T.State
    
    let mdp: T
    
    private(set) var currentState: State
    
    var availableActions: Set<T.Action>? {
        return mdp.getActions(forState: currentState)
    }
    
    init(mdp: T, initialState: State) {
        self.mdp = mdp
        currentState = initialState
    }
    
    /// Gets the actions that are available from the given state.
    func getActions(forState s: State) -> Set<Action>? {
        return mdp.getActions(forState: s)
    }

    
    mutating func select(action: Action) -> (State, Reward) {
        let transition = mdp.transition(fromState: currentState, byTakingAction: action)
        currentState = transition.0
        return transition
    }
}
