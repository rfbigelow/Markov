//
//  tableDrivenMDP.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A table-driven Markov Decision Process.
class TableDrivenMDP<Action: Hashable, State: Hashable>: MarkovDecisionProcess {
    
    /// Gets the states for this MDP.
    var states: Set<State> {
        return Set(transitions.keys)
    }

    /// The tabular representation of the MDP.
    internal var transitions: Dictionary<State, Dictionary<Action, WeightedDistribution<Transition<State>>>>
    
    /// Initializes this MDP with the following tables:
    /// - parameter transitionTable: A table that maps each state to a dictionary that describes the transitions from that state.
    /// - parameter rewardTable: A table that maps each state to the reward that is collected when that state is reached.
    init(transitionTable: Dictionary<State, Dictionary<Action, WeightedDistribution<Transition<State>>>>) {
        transitions = transitionTable
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
        guard let moves = transitions[s], let distribution = moves[a] else {
            return Reward()
        }
        return distribution.getExpectedValue(withTransform: { return $0.reward })
    }
    
    /// Gets the reward value for taking action a from state s to state next.
    func getReward(fromState s: State, forTakingAction a: Action, transitioningTo next: State) -> Reward {
        guard let moves = transitions[s], let distribution = moves[a], let transition = distribution.getEvent(matching: { $0.state == next }) else {
            return Reward()
        }
        return transition.reward
    }
    
    func getTransitions(fromState s: State, forTakingAction a: Action) -> [(Transition<State>, Double)]? {
        guard let moves = transitions[s], let distribution = moves[a] else {
            return nil
        }
        return Array(distribution)
    }
    
    func getTransitions(fromState s: State, forTakingAction a: Action, transitioningTo next: State) -> [(Transition<State>, Double)]? {
        guard let moves = transitions[s], let distribution = moves[a] else {
            return nil
        }
        return Array(distribution.filter({ $0.0.state == next }))
    }
    
    /// Performs a transition from the given state to a new state by doing the specified action.
    func transition(fromState s: State, byTakingAction a: Action) -> (State, Reward) {
        if let moves = transitions[s], let distribution = moves[a] {
            if let transition = distribution.getNext() {
                return (transition.state, transition.reward)
            }
        }
        return (s, 0)
    }
    
    /// Updates all rewards leading to state s with the given reward value.
    func updateAllRewards(forState s: State, withReward r: Reward) {
        for moves in transitions.values {
            for distribution in moves.values {
                for i in 0..<distribution.events.count {
                    if distribution.events[i].state == s {
                        distribution.events[i].reward = r
                    }
                }
            }
        }
    }
}
