//
//  main.swift
//  Markov
//
//  Created by Robert Bigelow on 11/4/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

typealias Reward = Double

enum TextWorldAction: Int { case north, south, east, west }

enum TextWorldState { case start, meadowOfTranquility, pitOfDespair, end }

let mdp = TableDrivenMDP<TextWorldAction, TextWorldState>(transitionTable:
    [TextWorldState.start: [TextWorldAction.north: DiscreteDistribution(weightedEvents: [(Transition(state: TextWorldState.meadowOfTranquility, reward: 20), 0.7),                                                                                                           (Transition(state: TextWorldState.pitOfDespair, reward: -1000),0.1), (Transition(state: TextWorldState.start, reward: 0), 0.2)])],
     TextWorldState.meadowOfTranquility: [TextWorldAction.east: DiscreteDistribution(weightedEvents: [(Transition(state: TextWorldState.end, reward: 100), 0.5),                                                                                                                                      (Transition(state: TextWorldState.meadowOfTranquility, reward: 20), 0.5)]), TextWorldAction.south: DiscreteDistribution(weightedEvents: [(Transition(state: TextWorldState.start, reward: 0), 0.5), (Transition(state: TextWorldState.meadowOfTranquility, reward: 20), 0.5)])]])

var currentState = TextWorldState.start
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

var environment = MdpEnvironment<TableDrivenMDP<TextWorldAction, TextWorldState>>(mdp: mdp, initialState: TextWorldState.start)
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
