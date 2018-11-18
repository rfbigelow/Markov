//
//  valueIterator.swift
//  Markov
//
//  Created by Robert Bigelow on 11/18/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

class ValueIterator<TModel: MarkovDecisionProcess> {
    
    let mdp: TModel
    let gamma: Double
    
    init(mdp: TModel, gamma: Double) {
        self.mdp = mdp
        self.gamma = gamma
    }
    
    /// Outputs an improved policy using value iteration.
    func getPolicy(withTolerance tolerance: Double) -> StochasticPolicy<TModel> {
        var iterations = 0
        var estimates: Dictionary<TModel.State, Reward> = Dictionary()
        var delta: Double
        let states = mdp.states
        var chosenActions: Dictionary<TModel.State, [TModel.Action]> = Dictionary()
        repeat {
            delta = 0.0
            chosenActions.removeAll()
            for state in states {
                if let actions = mdp.getActions(forState: state) {
                    let oldEstimate = estimates[state] ?? 0.0
                    let actionValues = actions.map({ ($0, getActionValue(forState: state, withAction: $0, mdp: mdp, discount: gamma, v: { estimates[$0] ?? 0.0 })) })
                    if let maxActionValue = actionValues.max(by: { $0.1 < $1.1 }) {
                        let stateValue = maxActionValue.1
                        let stateAction = maxActionValue.0
                        var currentChoices = chosenActions[state] ?? []
                        estimates[state] = stateValue
                        currentChoices.append(stateAction)
                        chosenActions[state] = currentChoices
                        delta = max(delta, abs(oldEstimate - stateValue))
                    }
                }
            }
            iterations += 1
        } while delta > tolerance
        print("Converged in \(iterations) iterations.")
        return StochasticPolicy<TModel>(actionMap: chosenActions)
    }
    
    static func getOptimalPolicy(forModel mdp:TModel, withTolerance epsilon: Double, withDiscount gamma: Double) -> StochasticPolicy<TModel> {
        let valueIterator = ValueIterator(mdp: mdp, gamma: gamma)
        return valueIterator.getPolicy(withTolerance: epsilon)
    }
}
