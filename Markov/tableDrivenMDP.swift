//
//  tableDrivenMDP.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

struct TableDrivenMDP<Action: Hashable, State: Hashable>: MarkovDecisionProcess {
    
    let transitions: Dictionary<State, Dictionary<Action, State>>
    let actions: Dictionary<Action, DiscreteDistribution<Action>>
    let rewards: Dictionary<State, Reward>
    
    init(transitionTable: Dictionary<State, Dictionary<Action, State>>,
         rewardTable: Dictionary<State, Reward>,
         actionTable: Dictionary<Action, DiscreteDistribution<Action>>) {
        transitions = transitionTable
        rewards = rewardTable
        actions = actionTable
    }
    
    func getActions(forState state: State) -> Set<Action>? {
        guard let moves = transitions[state] else {
            return nil
        }
        return Set<Action>(moves.keys)
    }
    
    func getReward(forState state: State) -> Reward {
        guard let reward = rewards[state] else {
            return Reward()
        }
        return reward
    }
    
    func transition(_ state: State, _ action: Action) -> State {
        if let moves = transitions[state], let fuzzyAction = actions[action] {
                do {
                    let actualAction = try fuzzyAction.getNext()
                    if let nextState = moves[actualAction] {
                        return nextState
                    }
                } catch DiscreteDistributionError.badRandomValue(let randomValue, let partialSum) {
                    print("Could not get next action due to bad random value \(randomValue) and partial sum \(partialSum).")
                } catch {
                    print("Unexpected error.")
                }
            }
        return state
    }   
}
