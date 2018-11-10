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
    
    let transitions: Dictionary<State, Dictionary<Action, DiscreteDistribution<(State, Reward)>>>
    let rewards: Dictionary<State, Reward>
    
    /// Initializes this MDP with the following tables:
    /// - parameter transitionTable: A table that maps each state to a dictionary that describes the transitions from that state.
    /// - parameter rewardTable: A table that maps each state to the reward that is collected when that state is reached.
    init(transitionTable: Dictionary<State, Dictionary<Action, DiscreteDistribution<(State, Reward)>>>,
         rewardTable: Dictionary<State, Reward>) {
        transitions = transitionTable
        rewards = rewardTable
    }
    
    /// Gets the actions that are available from the given state.
    func getActions(forState state: State) -> Set<Action>? {
        guard let moves = transitions[state] else {
            return nil
        }
        return Set<Action>(moves.keys)
    }
    
    /// Gets the reward value for the given state.
    func getReward(fromState s: State, forTakingAction a: Action) -> Reward {
        guard let reward = rewards[s] else {
            return Reward()
        }
        return reward
    }
    
    /// Performs a transition from the given state to a new state by doing the specified action.
    func transition(fromState s: State, byTakingAction a: Action) -> (State, Reward) {
        if let moves = transitions[s], let fuzzyState = moves[a] {
                do {
                        return try fuzzyState.getNext()
                } catch DiscreteDistributionError.badRandomValue(let randomValue, let partialSum) {
                    print("Could not get next action due to bad random value \(randomValue) and partial sum \(partialSum).")
                } catch {
                    print("Unexpected error.")
                }
            }
        return (s, 0)
    }   
}
