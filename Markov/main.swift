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

let mdp = TableDrivenMDP<Action, State>(transitionTable: [State.start: [Action.north: DiscreteDistribution(weightedEvents: [((State.meadowOfTranquility, 20), 0.7),
                                                                                                                            ((State.pitOfDespair, -1000),0.1), ((State.start, 0), 0.2)])],
                                                          State.meadowOfTranquility: [Action.east: DiscreteDistribution(weightedEvents: [((State.end, 100), 0.5),
                                                                                                                                         ((State.meadowOfTranquility, 20), 0.5)]),
                                                                                      Action.south: DiscreteDistribution(weightedEvents: [((State.start, 0), 0.5),
                                                                                                                                          ((State.meadowOfTranquility, 20), 0.5)])]],
                                         rewardTable: [State.start: 0, State.meadowOfTranquility: 20, State.pitOfDespair: -1000, State.end: 100])

var currentState = State.start
var score = 0.0
print("You are here: \(currentState)")
while let availableActions = mdp.getActions(forState: currentState){
    let action = availableActions.first!
    print("Heading \(action)...")
    let transition = mdp.transition(fromState: currentState, byTakingAction: action)
    currentState = transition.0
    score += transition.1
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
    let (state, reward) = environment.select(action: action)
    assert(state == environment.currentState)
    score += reward
    print("You are here: \(environment.currentState)")
}
print("Score is \(score).")
print("Game Over.")
