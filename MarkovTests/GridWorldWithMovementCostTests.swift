//
//  GridWorldWithMovementCostTests.swift
//  Markov
//
//  Created by Robert Bigelow on 11/17/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class GridWorldWithMovementCostTests: XCTestCase {
    private let outputPolicy = true
    private let outputStateValues = true
    
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
        addAttachment(string: playGridWorld(gridWorld: gridWorld, withPolicy: optimal.policy, currentState: &currentState, score: &score, plays: 100))
        XCTAssert(score == -47.0)
        
        if outputPolicy {
            addAttachment(string: createGrid(mdp: gridWorld, policy: optimal.policy))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: optimal.policy)
            addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }
    
    func testValueIteration() {
        let (optimal, _) = ValueIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.001, withDiscount: 0.90)
        addAttachment(string: playGridWorld(gridWorld: gridWorld, withPolicy: optimal, currentState: &currentState, score: &score, plays: 100))
        XCTAssert(score == -47.0)
        
        if outputPolicy {
            addAttachment(string: createGrid(mdp: gridWorld, policy: optimal))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: optimal)
            addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }
    
    func testQLearnerDecayingStep() {
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        let learner = QLearner(environment: environment, discount: 0.8, stepFunc: DecayingStepFunction(min: 0.1))
        let policy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.1)
        
        var steps = 0
        for _ in 0..<10000 {
            let initialState = GridSquare(x: 0, y: 0)
            steps += learner.learnBackwards(withPolicy: policy, fromState: initialState, forSteps: 100000)
        }
        print("Q-Learner took \(steps) steps.")
        
        let greedy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.0)
        addAttachment(string: playGridWorld(gridWorld: gridWorld, withPolicy: greedy, currentState: &currentState, score: &score, plays: 100))
        XCTAssert(currentState == GridSquare(x: 24, y: 24))

        if outputPolicy {
            addAttachment(string: createGrid(mdp: gridWorld, policy: greedy))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: greedy)
            addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }

    func testQLearnerConstantStep() {
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        let learner = QLearner(environment: environment, discount: 0.8, stepFunc: ConstantStepFunction(stepSize: 0.1))
        let policy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.1)
        
        var steps = 0
        for _ in 0..<10000 {
            steps += learner.learnBackwards(withPolicy: policy, fromState: GridSquare(x: 0, y: 0), forSteps: 100000)
        }
        print("Q-Learner took \(steps) steps.")
        
        let greedy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.0)
        addAttachment(string: playGridWorld(gridWorld: gridWorld, withPolicy: greedy, currentState: &currentState, score: &score, plays: 100))
        XCTAssert(currentState == GridSquare(x: 24, y: 24))
        
        if outputPolicy {
            addAttachment(string: createGrid(mdp: gridWorld, policy: greedy))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: greedy)
            addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }
}
