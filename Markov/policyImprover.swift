//
//  policyImprover.swift
//  Markov
//
//  Created by Robert Bigelow on 11/12/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

class PolicyImprover<TModel: MarkovDecisionProcess> {
    
    let mdp: TModel
    let gamma: Double
    
    init(mdp: TModel, gamma: Double) {
        self.mdp = mdp
        self.gamma = gamma
    }
    
    func improve<TPolicy: Policy>(policy: TPolicy, withValueFunction v: (TModel.State) -> Reward) -> StochasticPolicy<TModel>
        where TModel.State == TPolicy.State, TModel.Action == TPolicy.Action {

        var chosenActions: Dictionary<TModel.State, [TModel.Action]> = Dictionary()
        for state in mdp.states {
            if let actions = mdp.getActions(forState: state)?.filter({ policy.getProbability(fromState: state, ofTaking: $0) > 0.0 }) {
                var maxValue = -Double.greatestFiniteMagnitude
                for action in actions {
                    let currentValue = getActionValue(forState: state, withAction: action, mdp: mdp, discount: gamma, v: v)
                    if currentValue >= maxValue {
                        var currentChoices = chosenActions[state] ?? []
                        if currentValue > maxValue {
                            currentChoices.removeAll()
                            maxValue = currentValue
                        }
                        currentChoices.append(action)
                        chosenActions[state] = currentChoices
                    }
                }
            } else {
                print(state)
            }
        }
        return StochasticPolicy<TModel>(actionMap: chosenActions)
    }
    
    static func getOptimalPolicy(forModel mdp:TModel, withTolerance epsilon: Double, withDiscount gamma: Double) -> StochasticPolicy<TModel> {
        let improver = PolicyImprover(mdp: mdp, gamma: gamma)
        let evaluator = PolicyEvaluator(mdp: mdp, epsilon: epsilon, gamma: gamma)
        let initialPolicy = RandomSelectPolicy(mdp: mdp)
        
        var priorEstimates = evaluator.estimates
        evaluator.evaluate(policy: initialPolicy)

        var policy = improver.improve(policy: initialPolicy, withValueFunction: { evaluator.estimates[$0] ?? 0.0 })
        while !priorEstimates.elementsEqual(evaluator.estimates, by: { $0 == $1 }) {
            priorEstimates = evaluator.estimates
            evaluator.evaluate(policy: policy)
            policy = improver.improve(policy: policy, withValueFunction: { evaluator.estimates[$0] ?? 0.0 })
        }
        return policy
    }
}
