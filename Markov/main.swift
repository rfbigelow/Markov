//
//  main.swift
//  Markov
//
//  Created by Robert Bigelow on 11/4/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

typealias Reward = Double

enum Actions {
    case north
    case south
    case east
    case west
}

enum States {
    case start
    case meadowOfTranquility
    case pitOfDespair
    case end
}

let mdp = TableDrivenMDP<Actions, States>(transitionTable: [States.start: [Actions.north: States.meadowOfTranquility, Actions.east: States.pitOfDespair],
                                                           States.meadowOfTranquility: [Actions.east: States.end, Actions.south: States.start]],
                                         rewardTable: [States.start: 0, States.meadowOfTranquility: 20, States.pitOfDespair: -1000, States.end: 100],
                                         actionTable: [Actions.north: DiscreteDistribution(weightedEvents: [(Actions.north, 0.7), (Actions.south, 0.1), (Actions.east, 0.1), (Actions.west, 0.1)]),
                                                       Actions.east: DiscreteDistribution(weightedEvents: [(Actions.east, 0.5), (Actions.north, 0.5)]),
                                                       Actions.south: DiscreteDistribution(weightedEvents: [(Actions.south, 1.0)])])

var currentState = States.start
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
