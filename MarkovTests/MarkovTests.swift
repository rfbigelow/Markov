//
//  MarkovTests.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/7/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class MarkovTests: XCTestCase {
    var mdp: TableDrivenMDP<TextWorldAction, TextWorldState>!

    override func setUp() {
        mdp = TableDrivenMDP<TextWorldAction, TextWorldState>(transitionTable:
            [TextWorldState.start: [TextWorldAction.north: DiscreteDistribution(weightedEvents: [(TableDrivenMDP.Transition(state: TextWorldState.meadowOfTranquility, reward: 20), 0.7),                                                                                                           (TableDrivenMDP.Transition(state: TextWorldState.pitOfDespair, reward: -1000),0.1), (TableDrivenMDP.Transition(state: TextWorldState.start, reward: 0), 0.2)])],
             TextWorldState.meadowOfTranquility: [TextWorldAction.east: DiscreteDistribution(weightedEvents: [(TableDrivenMDP.Transition(state: TextWorldState.end, reward: 100), 0.5),                                                                                                                                      (TableDrivenMDP.Transition(state: TextWorldState.meadowOfTranquility, reward: 20), 0.5)]), TextWorldAction.south: DiscreteDistribution(weightedEvents: [(TableDrivenMDP.Transition(state: TextWorldState.start, reward: 0), 0.5), (TableDrivenMDP.Transition(state: TextWorldState.meadowOfTranquility, reward: 20), 0.5)])]])
    }

    override func tearDown() {
        mdp = nil
    }

    func testOverallPerformance() {
        // This is an example of a performance test case.
        self.measure {
            var currentState = TextWorldState.start
            var score = 0.0
            while let availableAction = mdp.getActions(forState: currentState){
                let action = availableAction.first!
                (currentState, _) = mdp.transition(fromState: currentState, byTakingAction: action)
                score += mdp.getReward(fromState: currentState, forTakingAction: action)
            }
        }
    }
}
