//
//  main.swift
//  Markov
//
//  Created by Robert Bigelow on 11/4/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

typealias Reward = Double

enum Action: Int { case north, south, east, west }

enum State { case start, meadowOfTranquility, pitOfDespair, end }

let mdp = TableDrivenMDP<Action, State>(transitionTable: [State.start: [Action.north: State.meadowOfTranquility, Action.east: State.pitOfDespair],
                                                           State.meadowOfTranquility: [Action.east: State.end, Action.south: State.start]],
                                         rewardTable: [State.start: 0, State.meadowOfTranquility: 20, State.pitOfDespair: -1000, State.end: 100],
                                         actionTable: [Action.north: DiscreteDistribution(weightedEvents: [(Action.north, 0.7), (Action.south, 0.1), (Action.east, 0.1), (Action.west, 0.1)]),
                                                       Action.east: DiscreteDistribution(weightedEvents: [(Action.east, 0.5), (Action.north, 0.5)]),
                                                       Action.south: DiscreteDistribution(weightedEvents: [(Action.south, 1.0)])])

var currentState = State.start
var score = 0.0
print("You are here: \(currentState)")
while let availableActions = mdp.getActions(forState: currentState){
    let action = availableActions.first!
    print("Heading \(action)...")
    currentState = mdp.transition(currentState, action)
    score += mdp.getReward(forState: currentState)
    print("You are here: \(currentState)")
}
print("Score is \(score).")
print("Game Over.")

print("Environment Test")

var environment = MdpEnvironment<TableDrivenMDP<Action, State>>(mdp: mdp, initialState: State.start)
score = 0.0
print("You are here: \(environment.currentState)")
while let action = environment.availableActions?.randomElement() {
    print("Heading \(action)...")
    let (reward, state) = environment.select(action: action)
    assert(state == environment.currentState)
    score += reward
    print("You are here: \(environment.currentState)")
}
print("Score is \(score).")
print("Game Over.")
