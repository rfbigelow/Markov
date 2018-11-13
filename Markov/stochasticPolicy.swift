//
//  stochasticPolicy.swift
//  Markov
//
//  Created by Robert Bigelow on 11/12/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

struct StochasticPolicy<T: MarkovDecisionProcess>: Policy {
    typealias Action = T.Action
    typealias State = T.State
    
    private var actionDistributions: Dictionary<State, BinDistribution<Action>> = Dictionary()
    
    init(actionMap: Dictionary<State, [Action]>) {
        for element in actionMap {
            actionDistributions[element.key] = BinDistribution(events: element.value)
        }
    }
    
    /// Gets the probability of taking action a from state s.
    func getProbability(fromState s: State, ofTaking a: Action) -> Double {
        if let distribution = actionDistributions[s] {
            return distribution.getProbability(forEventMatchedBy: { $0 == a })
        }
        return 0.0
    }
    
    /// Gets an action to take from the state s according to this policy.
    func getAction(forState s: State) -> Action? {
        return actionDistributions[s]?.getNext()
    }

}
