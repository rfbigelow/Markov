//
//  MarkovTests.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/7/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class MarkovTests: XCTestCase {
    var mdp: TableDrivenMDP<Actions, States>!

    override func setUp() {
        mdp = TableDrivenMDP<Actions, States>(transitionTable: [States.start: [Actions.north: States.meadowOfTranquility, Actions.east: States.pitOfDespair],
                                                                    States.meadowOfTranquility: [Actions.east: States.end, Actions.south: States.start]],
                                                  rewardTable: [States.start: 0, States.meadowOfTranquility: 20, States.pitOfDespair: -1000, States.end: 100],
                                                  actionTable: [Actions.north: DiscreteDistribution(weightedEvents: [(Actions.north, 0.7), (Actions.south, 0.1), (Actions.east, 0.1), (Actions.west, 0.1)]),
                                                                Actions.east: DiscreteDistribution(weightedEvents: [(Actions.east, 0.5), (Actions.north, 0.5)]),
                                                                Actions.south: DiscreteDistribution(weightedEvents: [(Actions.south, 1.0)])])
    }

    override func tearDown() {
        mdp = nil
    }

    func testOverallPerformance() {
        // This is an example of a performance test case.
        self.measure {
            var currentState = States.start
            var score = 0.0
            while let availableActions = mdp.getActions(forState: currentState){
                let action = availableActions.first!
                currentState = mdp.transition(currentState, action)
                score += mdp.getReward(forState: currentState)
            }
        }
    }

}
