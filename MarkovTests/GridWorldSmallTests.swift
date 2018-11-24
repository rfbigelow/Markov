//
//  GridWorldSmallTests.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/20/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class GridWorldSmallTests: XCTestCase {
    private let outputPolicy = false
    private let outputStateValues = false

    var gridWorld: GridWorld!
    var score = 0.0
    var currentState = GridSquare(x: 0, y: 0)
    
    override func setUp() {
        gridWorld = GridWorld(rows: 5, columns: 5, movementCost: -1.0)
        score = 0.0
        currentState = GridSquare(x: 0, y: 0)
    }
    
    override func tearDown() {
        gridWorld = nil
    }
    
    func testStochasticRewardWithPolicyIteration() {
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.engageClaw, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.engageClaw, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.engageClaw, withProbability: 0.005, withCost: -1.0)
        
        let transitions = gridWorld.getTransitions(fromState: GridSquare(x: 2, y: 2), forTakingAction: GridAction.engageClaw)
        XCTAssertNotNil(transitions)
        
        let policy = PolicyIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.001, withDiscount: 0.99)
        playGridWorld(gridWorld: gridWorld, withPolicy: policy, currentState: &currentState, score: &score, plays: 100)

        if outputPolicy {
            print(createGrid(mdp: gridWorld, policy: policy))
        }

        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: policy)
            print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }

    func testStochasticRewardWithValueIteration() {
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.engageClaw, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.engageClaw, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.engageClaw, withProbability: 0.005, withCost: -1.0)

        let transitions = gridWorld.getTransitions(fromState: GridSquare(x: 2, y: 2), forTakingAction: GridAction.engageClaw)
        XCTAssertNotNil(transitions)
        
        let policy = ValueIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.001, withDiscount: 0.99)
        playGridWorld(gridWorld: gridWorld, withPolicy: policy, currentState: &currentState, score: &score, plays: 100)
        
        if outputPolicy {
            print(createGrid(mdp: gridWorld, policy: policy))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: policy)
            print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }

    func testStochasticRewardWithQLearningConstantStep() {
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.engageClaw, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.engageClaw, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.engageClaw, withProbability: 0.005, withCost: -1.0)
        
        let transitions = gridWorld.getTransitions(fromState: GridSquare(x: 2, y: 2), forTakingAction: GridAction.engageClaw)
        XCTAssertNotNil(transitions)
        
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        let learner = QLearner(environment: environment, discount: 0.99, stepFunc: ConstantStepFunction(stepSize: 0.1))
        let policy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0)},
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1)},
            epsilon: 0.25)
        
        var steps = 0
        for _ in 0..<10000 {
            steps += learner.learn(withPolicy: policy, fromState: GridSquare(x: 0, y: 0), forSteps: 100)
        }
        print("Q-learner took \(steps) steps.")
        
        let greedyPolicy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0)},
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1)},
            epsilon: 0.0)
        
        playGridWorld(gridWorld: gridWorld, withPolicy: greedyPolicy, currentState: &currentState, score: &score, plays: 100)
       
        if outputPolicy {
            print(createGrid(mdp: gridWorld, policy: greedyPolicy))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: greedyPolicy)
            print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }

    func testStochasticRewardWithQLearningDecayingStep() {
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.engageClaw, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.engageClaw, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.engageClaw, withProbability: 0.005, withCost: -1.0)
        
        let transitions = gridWorld.getTransitions(fromState: GridSquare(x: 2, y: 2), forTakingAction: GridAction.engageClaw)
        XCTAssertNotNil(transitions)
        
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        let learner = QLearner(environment: environment, discount: 0.99, stepFunc: DecayingStepFunction())
        let policy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0)},
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1)},
            epsilon: 0.25)
        
        var steps = 0
        for _ in 0..<100 {
            steps += learner.learnBackwards(withPolicy: policy, fromState: GridSquare(x: 0, y: 0), forSteps: 100)
        }
        print("Q-learner took \(steps) steps.")
        
        let greedyPolicy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0)},
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1)},
            epsilon: 0.0)
        
        playGridWorld(gridWorld: gridWorld, withPolicy: greedyPolicy, currentState: &currentState, score: &score, plays: 100)
        
        if outputPolicy {
            print(createGrid(mdp: gridWorld, policy: greedyPolicy))
        }
        
        if outputStateValues {
            let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
            policyEvaluator.evaluate(policy: greedyPolicy)
            print(createGrid(mdp: gridWorld, withValueFunction: { (s: GridWorld.State) -> Reward in policyEvaluator.estimates[s] ?? 0.0}, format: "%.2f"))
        }
    }
}
