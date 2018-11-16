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
        playGridWorld(gridWorld: gridWorld, withPolicy: RandomSelectPolicy(mdp: gridWorld), currentState: &currentState, score: &score, plays: 100)
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
        playGridWorld(gridWorld: gridWorld, withPolicy: RandomSelectPolicy(mdp: gridWorld), currentState: &currentState, score: &score, plays: 100)
    }
    
    func testPolicyEvaluatorAndImprover() {
        gridWorld.addNexus(from: GridSquare(x: 1, y: 4), to: GridSquare(x: 1, y: 0), withReward: 10.0)
        gridWorld.addNexus(from: GridSquare(x: 3, y: 4), to: GridSquare(x: 3, y: 2), withReward: 5.0)
        
        let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.01, discount: 0.9)
        let policy = RandomSelectPolicy(mdp: gridWorld)

        policyEvaluator.evaluate(policy: policy)
        
        let policyImprover = PolicyImprover(mdp: gridWorld, gamma: 0.9)
        let improvedPolicy = policyImprover.improve(policy: policy, withValueFunction: { policyEvaluator.estimates[$0] ?? 0.0 })
        let priorEstimates = policyEvaluator.estimates

        policyEvaluator.evaluate(policy: improvedPolicy)

        for current in policyEvaluator.estimates {
            XCTAssert(current.value >= priorEstimates[current.key]!)
        }
    }
    
    func testOptimalPolicy() {
        let optimal = PolicyImprover.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.4, withDiscount: 0.95)
        playGridWorld(gridWorld: gridWorld, withPolicy: optimal, currentState: &currentState, score: &score, plays: 100)
        XCTAssert(score == 0.0, "Optimal policy failed to avoid the walls.")
    }
    
    func testEpsilonGreedyPolicy() {
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        
        // Cheat by using DP to get an optimal policy. This will back our Q(s,a) function, since we don't have a learner.
        let optimal = PolicyImprover.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.1, withDiscount: 0.9)
        let policyEvaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.01, discount: 0.9)
        policyEvaluator.evaluate(policy: optimal)
        
        // Now create our epsilon-greedy policy. It will have perfect knowledge learned from our DP policy evaluator.
        // However, it will sometimes make a "mistake" by going off-policy, according to our epsilon value.
        let egreedy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { getActionValue(
                forState: $0,
                withAction: $1,
                mdp: self.gridWorld,
                discount: 0.9,
                v: { policyEvaluator.estimates[$0] ?? 0.0})},
            epsilon: 0.2)
        
        // Make a bunch of moves so we can see how many mistakes were made.
        playGridWorld(gridWorld: gridWorld, withPolicy: egreedy, currentState: &currentState, score: &score, plays: 100)
        
        // Just make sure it didn't play a perfect game. If it did, then it did not explore at all.
        XCTAssert(score < 0.0, "Epsilon-greedy played a perfect game. That doesn't seem right.")
    }
    
    func testQLearner() {
        gridWorld.addVortex(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
        let learner = QLearner(environment: environment, discount: 0.9, stepSize: 0.0001)
        let policy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.1)
        self.measure {
            for _ in 0..<1 {
                learner.learn(withPolicy: policy, fromState: GridSquare(x: 0, y: 0), forSteps: 100)
            }
        }
        
        let optimal = PolicyImprover.getOptimalPolicy(forModel: gridWorld, withTolerance: 0.1, withDiscount: 0.9)
        let evaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.1, discount: 0.9)
        evaluator.evaluate(policy: optimal)
        
        var maxDiff = 0.0
        for (state, actionValues) in learner.estimates {
            let estimate = actionValues.values.reduce(0.0, +) / Double(actionValues.count)
            let evalEstimate = evaluator.estimates[state] ?? 0.0
            let diff = abs(estimate - evalEstimate)
            maxDiff = max(diff, maxDiff)
        }
        print("Max diff: \(maxDiff)")
        
        let greedy = EpsilonGreedyPolicy(
            actionsForStateDelegate: { environment.getActions(forState: $0) },
            actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
            epsilon: 0.0)
        playGridWorld(gridWorld: gridWorld, withPolicy: greedy, currentState: &currentState, score: &score, plays: 100)
    }
}

func playGridWorld<T: Policy>(gridWorld: GridWorld, withPolicy policy: T, currentState: inout GridSquare, score: inout Double, plays: Int)
where T.Action == GridWorld.Action, T.State == GridWorld.State {
    print(currentState, score)
    for _ in 0..<plays {
        if let action = policy.getAction(forState: currentState) {
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
