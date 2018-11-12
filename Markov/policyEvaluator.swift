//
//  policyEvaluator.swift
//  Markov
//
//  Created by Robert Bigelow on 11/11/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

class PolicyEvaluator<T: MarkovDecisionProcess> {
    
    var estimates: Dictionary<T.State, Reward> = Dictionary()
    let epsilon: Double
    let gamma: Double
    let mdp: T
    
    var iterations: Int = 0
    
    init(mdp: T, epsilon: Double, gamma: Double) {
        self.mdp = mdp
        self.epsilon = epsilon
        self.gamma = gamma
    }
    
    func evaluate<TPolicy: Policy>(policy: TPolicy) where TPolicy.State == T.State, TPolicy.Action == T.Action {
        iterations = 0
        estimates.removeAll()
        var maxDelta: Double
        let states = mdp.states
        repeat {
            maxDelta = 0.0
            for state in states {
                if let actions = mdp.getActions(forState: state) {
                    let oldEstimate = estimates[state] ?? 0.0
                    var sum = 0.0
                    for action in actions {
                        let actionProb = policy.getProbability(fromState: state, ofTaking: action)
                        let actionReward = mdp.getReward(fromState: state, forTakingAction: action)
                        let (nextState, _) = mdp.transition(fromState: state, byTakingAction: action)
                        let nextStateValue = estimates[nextState] ?? 0.0
                        sum += actionProb * (actionReward + gamma * nextStateValue)
                    }
                    estimates[state] = sum
                    let delta = abs(oldEstimate - sum)
                    if delta > maxDelta {
                        maxDelta = delta
                    }
                }
            }
            iterations += 1
        } while maxDelta > epsilon
        print("Converged in \(iterations) iterations.")
    }
    
    func getValue(forState state: T.State) -> Reward {
        return estimates[state] ?? 0.0
    }
}
