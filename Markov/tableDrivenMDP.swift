//
//  tableDrivenMDP.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A table-driven Markov Decision Process.
class TableDrivenMDP<Action: Hashable, State: Hashable>: MarkovDecisionProcess {
    struct Transition: Equatable {
        let state: State
        var reward: Reward
    }

    var transitions: Dictionary<State, Dictionary<Action, DiscreteDistribution<Transition>>>
    
    /// Initializes this MDP with the following tables:
    /// - parameter transitionTable: A table that maps each state to a dictionary that describes the transitions from that state.
    /// - parameter rewardTable: A table that maps each state to the reward that is collected when that state is reached.
    init(transitionTable: Dictionary<State, Dictionary<Action, DiscreteDistribution<Transition>>>) {
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
    
    func getReward(fromState s: State, forTakingAction a: Action, transitioningTo next: State) -> Reward {
        guard let moves = transitions[s], let distribution = moves[a], let transition = distribution.getEvent(matching: { $0.state == next }) else {
            return Reward()
        }
        return transition.reward
    }
    
    /// Performs a transition from the given state to a new state by doing the specified action.
    func transition(fromState s: State, byTakingAction a: Action) -> (State, Reward) {
        if let moves = transitions[s], let fuzzyState = moves[a] {
                do {
                        let transition = try fuzzyState.getNext()
                        return (transition.state, transition.reward)
                } catch DiscreteDistributionError.badRandomValue(let randomValue, let partialSum) {
                    print("Could not get next action due to bad random value \(randomValue) and partial sum \(partialSum).")
                } catch {
                    print("Unexpected error.")
                }
            }
        return (s, 0)
    }
    
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
