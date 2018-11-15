//
//  policyEvaluator.swift
//  Markov
//
//  Created by Robert Bigelow on 11/11/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// Policy evaluators use a model to iteratively build an estimate of the state-value function for following
/// a given policy.
class PolicyEvaluator<T: MarkovDecisionProcess> {
    
    var estimates: Dictionary<T.State, Reward> = Dictionary()
    let tolerance: Double
    let discount: Double
    let mdp: T
    
    var iterations: Int = 0
    
    init(mdp: T, tolerance: Double, discount: Double) {
        self.mdp = mdp
        self.tolerance = tolerance
        self.discount = discount
    }
    
    func evaluate<TPolicy: Policy>(policy: TPolicy) where TPolicy.State == T.State, TPolicy.Action == T.Action {
        iterations = 0
        estimates.removeAll()
        var maxDelta: Double
        let states = mdp.states
        repeat {
            maxDelta = 0.0
            for state in states {
                let oldEstimate = estimates[state] ?? 0.0
                let stateValue = getStateValue(forState: state, withModel: mdp, policy: policy, discount: discount, v: { estimates[$0] ?? 0.0 })
                estimates[state] = stateValue
                let delta = abs(oldEstimate - stateValue)
                if delta > maxDelta {
                    maxDelta = delta
                }
            }
            iterations += 1
        } while maxDelta > tolerance
        print("Converged in \(iterations) iterations.")
    }
}
