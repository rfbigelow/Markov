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
            let nextStateValue = v(nextState)
            sum += actionProb * (actionReward + discount * nextStateValue)
        }
    }
    return sum
}

func getActionValue<TModel: MarkovDecisionProcess, TPolicy: Policy>(
    forState state: TModel.State,
    withAction action: TModel.Action,
    mdp: TModel,
    policy: TPolicy,
    discount: Double,
    q:(TModel.State, TModel.Action) -> Reward) -> Reward where TModel.State == TPolicy.State, TModel.Action == TPolicy.Action {
    var sum = 0.0
    if let transitions = mdp.getTransitions(fromState: state, forTakingAction: action) {
        for (transition, probability) in transitions {
            var maxQ = 0.0
            if let nextActions = mdp.getActions(forState: transition.state) {
                maxQ = nextActions.map({ q(transition.state, $0) }).max() ?? maxQ
            }
            sum += probability * (transition.reward + discount * maxQ)
        }
    }
    return sum
}
