//
//  GridWorldTests.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/11/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class GridWorldTests: XCTestCase {
    
    var gridWorld: GridWorld!
    var score = 0.0
    var currentState = GridSquare(x: 0, y: 0)

    override func setUp() {
        gridWorld = GridWorld(rows: 5, columns: 5)
        score = 0.0
        currentState = GridSquare(x: 0, y: 0)
    }

    override func tearDown() {
        gridWorld = nil
    }

    func testGridWorldPlays() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print(currentState, score)
        for _ in 0..<10 {
            if let actions = gridWorld.getActions(forState: currentState), let action = actions.randomElement() {
                var reward = 0.0
                (currentState, reward) = gridWorld.transition(fromState: currentState, byTakingAction: action)
                score += reward
                print(action, reward)
                print(currentState, score)
            }
        }
        print(score)
    }
    
    func testNexusPlays() {
        gridWorld.addNexus(from: GridSquare(x: 3, y: 3), to: GridSquare(x: 0, y: 0), withReward: 10.0)
        playGridWorldRandomly(gridWorld: gridWorld, currentState: &currentState, score: &score, plays: 100)
    }
    
    func testAddVortex() {
        gridWorld.addVortex(at: GridSquare(x: 2, y: 2), withReward: -100)
        (currentState, _) = gridWorld.transition(fromState: currentState, byTakingAction: GridAction.up)
        (currentState, _) = gridWorld.transition(fromState: currentState, byTakingAction: GridAction.up)
        (currentState, _) = gridWorld.transition(fromState: currentState, byTakingAction: GridAction.right)
        
        var reward = 0.0
        (currentState, reward) = gridWorld.transition(fromState: currentState, byTakingAction: GridAction.right)
        XCTAssert(reward == -100)
        
        let availableActions = gridWorld.getActions(forState: currentState)
        XCTAssertNil(availableActions)
    }
    
    func testVortexPlays() {
        gridWorld.addVortex(at: GridSquare(x: 2, y: 2), withReward: -100)
        playGridWorldRandomly(gridWorld: gridWorld, currentState: &currentState, score: &score, plays: 100)
    }
    
    func testPolicyEvaluator() {
        gridWorld.addNexus(from: GridSquare(x: 1, y: 4), to: GridSquare(x: 1, y: 0), withReward: 10.0)
        gridWorld.addNexus(from: GridSquare(x: 3, y: 4), to: GridSquare(x: 3, y: 2), withReward: 5.0)
        
        let policyEvaluator = PolicyEvaluator(mdp: gridWorld, epsilon: 0.01, gamma: 0.9)
        let policy = RandomSelectPolicy(mdp: gridWorld)
        self.measure {
            policyEvaluator.evaluate(policy: policy)
        }
        for estimate in policyEvaluator.estimates.sorted(by: { $0.key.x < $1.key.x || (($0.key.x == $1.key.x) && ($0.key.y < $1.key.y))}) {
            print(estimate)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

func playGridWorldRandomly(gridWorld: GridWorld, currentState: inout GridSquare, score: inout Double, plays: Int) {
    print(currentState, score)
    for _ in 0..<plays {
        if let actions = gridWorld.getActions(forState: currentState), let action = actions.randomElement() {
            var reward = 0.0
            (currentState, reward) = gridWorld.transition(fromState: currentState, byTakingAction: action)
            score += reward
            print(action, reward)
            print(currentState, score)
        }
        else {
            break
        }
    }
    print(score)

}
