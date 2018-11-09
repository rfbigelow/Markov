//
//  mdpEnvironment.swift
//  Markov
//
//  Created by Robert Bigelow on 11/9/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// An environment provided by a Markov decision process
struct MdpEnvironment<T: MarkovDecisionProcess>: Environment {
    typealias Action = T.Action
    typealias State = T.State
    
    let mdp: T
    
    private(set) var currentState: State
    
    init(mdp: T, initialState: State) {
        self.mdp = mdp
        currentState = initialState
    }
    
    mutating func select(action: Action) -> (Reward, State) {
        currentState = mdp.transition(currentState, action)
        let reward = mdp.getReward(forState: currentState)
        return (reward, currentState)
    }
}
