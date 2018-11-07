//
//  tableDrivenMDP.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// A table-driven Markov Decision Process.
struct TableDrivenMDP<Action: Hashable, State: Hashable>: MarkovDecisionProcess {
    
    let transitions: Dictionary<State, Dictionary<Action, State>>
    let actions: Dictionary<Action, DiscreteDistribution<Action>>
    let rewards: Dictionary<State, Reward>
    
    /// Initializes this MDP with the following tables:
    /// - parameter transitionTable: A table that maps each state to a dictionary that describes the transitions from that state.
    /// - parameter rewardTable: A table that maps each state to the reward that is collected when that state is reached.
    /// - parameter actionTable: A table that maps each action to a distribution of actions. This adds a stochastic element to the MDP.
    init(transitionTable: Dictionary<State, Dictionary<Action, State>>,
         rewardTable: Dictionary<State, Reward>,
         actionTable: Dictionary<Action, DiscreteDistribution<Action>>) {
        transitions = transitionTable
        rewards = rewardTable
        actions = actionTable
    }
    
    /// Gets the actions that are available from the given state.
    func getActions(forState state: State) -> Set<Action>? {
        guard let moves = transitions[state] else {
            return nil
        }
        return Set<Action>(moves.keys)
    }
    
    /// Gets the reward value for the given state.
    func getReward(forState state: State) -> Reward {
        guard let reward = rewards[state] else {
            return Reward()
        }
        return reward
    }
    
    /// Performs a transition from the given state to a new state by doing the specified action.
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
