//
//  GridWorldWithMovementCostTests.swift
//  Markov
//
//  Created by Robert Bigelow on 11/17/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class GridWorldWithMovementCostTests: XCTestCase {
    
    var gridWorld: GridWorld!
    var score = 0.0
    var currentState = GridSquare(x: 0, y: 0)
    
    override func setUp() {
        gridWorld = GridWorld(rows: 25, columns: 25, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 24, y: 24), withReward: 0.0)
        score = 0.0
        currentState = GridSquare(x: 0, y: 0)
    }
    
    override func tearDown() {
        gridWorld = nil
    }
    
    func testPolicyIteration() {
        let optimal = PolicyIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.001, withDiscount: 0.99)
        playGridWorld(gridWorld: gridWorld, withPolicy: optimal, currentState: &currentState, score: &score, plays: 100)
        XCTAssert(score == -47.0)
//        print(createGrid(mdp: gridWorld, policy: optimal))
        let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
        policyEvaluator.evaluate(policy: optimal)
        print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))

    }
    
    func testValueIteration() {
        let optimal = ValueIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.001, withDiscount: 0.90)
        playGridWorld(gridWorld: gridWorld, withPolicy: optimal, currentState: &currentState, score: &score, plays: 100)
        XCTAssert(score == -47.0)
//        print(createGrid(mdp: gridWorld, policy: optimal))
        let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
        policyEvaluator.evaluate(policy: optimal)
        print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
    }
    
    func testQLearner() {
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        let learner = QLearner(environment: environment, discount: 0.9, stepSize: 0.1)
        let policy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.1)
        
        for _ in 0..<15000 {
            learner.learn(withPolicy: policy, fromState: GridSquare(x: 0, y: 0), forSteps: 100)
        }
        
        let greedy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.0)
        playGridWorld(gridWorld: gridWorld, withPolicy: greedy, currentState: &currentState, score: &score, plays: 100)
        XCTAssert(currentState == GridSquare(x: 24, y: 24))
//        print(createGrid(mdp: gridWorld, policy: greedy))
        let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
        policyEvaluator.evaluate(policy: greedy)
        print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
    }

}
