//
//  valueFunctions.swift
//  Markov
//
//  Created by Robert Bigelow on 11/12/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

func getStateValue<TModel: MarkovDecisionProcess, TPolicy: Policy>(
    forState state: TModel.State,
    withModel mdp: TModel,
    policy: TPolicy,
    discount: Double,
    v:(TModel.State) -> Reward) -> Reward where TModel.State == TPolicy.State, TModel.Action == TPolicy.Action {
    var sum = 0.0
    if let actions = mdp.getActions(forState: state) {
        for action in actions {
            let actionProb = policy.getProbability(fromState: state, ofTaking: action)
            let actionReward = mdp.getReward(fromState: state, forTakingAction: action)
            let (nextState, _) = mdp.transition(fromState: state, byTakingAction: action)
            sum += actionProb * (actionReward + discount * v(nextState))
        }
    }
    return sum
}

func getActionValue<TModel: MarkovDecisionProcess>(
    forState state: TModel.State,
    withAction action: TModel.Action,
    mdp: TModel,
    discount: Double,
    v:(TModel.State) -> Reward) -> Reward {
    var sum = 0.0
    if let transitions = mdp.getTransitions(fromState: state, forTakingAction: action) {
        for (transition, probability) in transitions {
            sum += probability * (transition.reward + discount * v(transition.state))
        }
    }
    return sum
}
