//
//  QLearningTests.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/24/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class QLearningTests: XCTestCase {
    struct TestInput {
        let discount: Double
        let stepSize: Double
        let epsilon: Double
        let episodes: Int
    }
    
    let discountInputs: [TestInput] = [
        TestInput(discount: 0.8, stepSize: 0.1, epsilon: 0.1, episodes: 1000),
        TestInput(discount: 0.9, stepSize: 0.1, epsilon: 0.1, episodes: 1000),
        TestInput(discount: 0.99, stepSize: 0.1, epsilon: 0.1, episodes: 1000),
    ]

    let epsilonInputs: [TestInput] = [
        TestInput(discount: 0.9, stepSize: 0.01, epsilon: 0.1, episodes: 10000),
        TestInput(discount: 0.9, stepSize: 0.01, epsilon: 0.15, episodes: 10000),
        TestInput(discount: 0.9, stepSize: 0.01, epsilon: 0.2, episodes: 10000),
        ]

    func testSmallGridWithConstantStepVaryingDiscount() {
        testSmallGrid(
            inputs: discountInputs,
            createStepFunction: { ConstantStepFunction(stepSize: $0.stepSize) },
            learningFunction: { $0.learn(withPolicy: $1, fromState: $2, forSteps: $3)})
    }
    
    func testSmallGridWithDecayingStepVaryingDiscount() {
        testSmallGrid(inputs: discountInputs, createStepFunction: { DecayingStepFunction(min: $0.stepSize) },
                      learningFunction: { $0.learn(withPolicy: $1, fromState: $2, forSteps: $3)})
    }
    
    func testSmallGridWithDecayingStepVaryingEpsilon() {
        testSmallGrid(inputs: epsilonInputs, createStepFunction: { DecayingStepFunction(min: $0.stepSize) },
                      learningFunction: { $0.learn(withPolicy: $1, fromState: $2, forSteps: $3)})
    }

    func testSmallGridWithDecayingStepVaryingEpsilonBackwards() {
        testSmallGrid(inputs: epsilonInputs, createStepFunction: { DecayingStepFunction(min: $0.stepSize) },
                      learningFunction: { $0.learnBackwards(withPolicy: $1, fromState: $2, forSteps: $3)})
    }

    func testLargeGridWithConstantStepVaryingDiscount() {
        testSmallGrid(
            inputs: discountInputs,
            createStepFunction: { ConstantStepFunction(stepSize: $0.stepSize) },
            learningFunction: { $0.learn(withPolicy: $1, fromState: $2, forSteps: $3)})
    }
    
    func testLargeGridWithDecayingStepVaryingDiscount() {
        testSmallGrid(inputs: discountInputs, createStepFunction: { DecayingStepFunction(min: $0.stepSize) },
                      learningFunction: { $0.learn(withPolicy: $1, fromState: $2, forSteps: $3)})
    }
    
    func testLargeGridWithDecayingStepVaryingEpsilon() {
        testSmallGrid(inputs: epsilonInputs, createStepFunction: { DecayingStepFunction(min: $0.stepSize) },
                      learningFunction: { $0.learn(withPolicy: $1, fromState: $2, forSteps: $3)})
    }
    
    func testLargeGridWithDecayingStepVaryingEpsilonBackwards() {
        testSmallGrid(inputs: epsilonInputs, createStepFunction: { DecayingStepFunction(min: $0.stepSize) },
                      learningFunction: { $0.learnBackwards(withPolicy: $1, fromState: $2, forSteps: $3)})
    }
    
    func testSmallGrid<TStepFunction: StepFunction>(
        inputs: [TestInput],
        createStepFunction: (TestInput) -> TStepFunction,
        learningFunction: (QLearner<MdpEnvironment<GridWorld>, TStepFunction>, EpsilonGreedyPolicy<GridSquare, GridAction>, GridSquare, Int) -> Int) where TStepFunction.State == GridSquare, TStepFunction.Action == GridAction {
        let gridWorld = GridWorld(rows: 5, columns: 5, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.dig, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.dig, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.dig, withProbability: 0.005, withCost: -1.0)

        var iterationRecords = [Int]()
        var iterationsPerEpisodeRecords = [Double]()
        var scoreRecords = [Double]()
        for input in inputs {
            let suffix = "Step size: \(input.stepSize) Discount: \(input.discount) Epsilon: \(input.epsilon) Episodes: \(input.episodes)"
            let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
            let learner = QLearner(environment: environment, discount: input.discount, stepFunc: createStepFunction(input))
            let policy = EpsilonGreedyPolicy(
                actionsForStateDelegate: { environment.getActions(forState: $0)},
                actionValueDelegate: { learner.getEstimate(forState: $0, action: $1)},
                epsilon: input.epsilon)
            
            var steps = 0
            XCTContext.runActivity(named: "Get optimal policy with " + suffix, block: {_ in
                let episodes = input.episodes
                for _ in 0..<episodes {
                    steps += learningFunction(learner, policy, GridSquare(x: 0, y: 0), 1000)
                }
                let stepsPerEpisode = Double(steps)/Double(episodes)
                addAttachment(string: suffix + " finished in \(steps) steps and \(episodes) episodes for \(stepsPerEpisode) steps/episode")
                iterationRecords.append(steps)
                iterationsPerEpisodeRecords.append(stepsPerEpisode)
            })
            
            XCTContext.runActivity(named: "Evaluate policy for " + suffix, block: {_ in
                let greedyPolicy = EpsilonGreedyPolicy(
                    actionsForStateDelegate: { environment.getActions(forState: $0) },
                    actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
                    epsilon: 0.0)
                let evaluator = PolicyEvaluator(mdp: gridWorld, tolerance: 0.001, discount: 0.99)
                evaluator.evaluate(policy: greedyPolicy)
                let totalValue = evaluator.estimates.values.reduce(0.0, +)
                addAttachment(string: "Total value for " + suffix + " is \(totalValue)")
                addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { evaluator.estimates[$0] ?? 0.0 }, format: "%.2f"))
                addAttachment(string: createGrid(mdp: gridWorld, policy: greedyPolicy))
                scoreRecords.append(totalValue)
            })
        }
        
        let inputsText = inputs.map({ "(\($0.discount), \($0.stepSize), \($0.epsilon))" }).joined(separator: ", ")
        let iterationsText = iterationRecords.map({ String($0) }).joined(separator: ", ")
        let iterationsPerEpisodeText = iterationsPerEpisodeRecords.map({ String($0) }).joined(separator: ", ")
        let totalValueText = scoreRecords.map({ String($0) }).joined(separator: ", ")
        let report = "Inputs: \(inputsText)\nIterations: \(iterationsText)\nIterations per episode: \(iterationsPerEpisodeText)\nTotals: \(totalValueText)"
        addAttachment(string: report)
    }
    
    func testLargeGrid<TStepFunction: StepFunction>(
        inputs: [TestInput],
        createStepFunction: (TestInput) -> TStepFunction,
        learningFunction: (QLearner<MdpEnvironment<GridWorld>, TStepFunction>, EpsilonGreedyPolicy<GridSquare, GridAction>, GridSquare, Int) -> Int) where TStepFunction.State == GridSquare, TStepFunction.Action == GridAction {
        let gridWorld = GridWorld(rows: 25, columns: 25, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 24, y: 24), withReward: 0.0)

        var iterationRecords = [Int]()
        var iterationsPerEpisodeRecords = [Double]()
        var scoreRecords = [Double]()
        for input in inputs {
            let suffix = "Step size: \(input.stepSize) Discount: \(input.discount) Epsilon: \(input.epsilon) Episodes: \(input.episodes)"
            let environment = MdpEnvironment(mdp: gridWorld, initialState: GridSquare(x: 0, y: 0))
            let learner = QLearner(environment: environment, discount: input.discount, stepFunc: createStepFunction(input))
            let policy = EpsilonGreedyPolicy(
                actionsForStateDelegate: { environment.getActions(forState: $0)},
                actionValueDelegate: { learner.getEstimate(forState: $0, action: $1)},
                epsilon: input.epsilon)
            
            var steps = 0
            XCTContext.runActivity(named: "Get optimal policy with " + suffix, block: {_ in
                let episodes = input.episodes
                for _ in 0..<episodes {
                    steps += learningFunction(learner, policy, GridSquare(x: 0, y: 0), 1000)
                }
                let stepsPerEpisode = Double(steps)/Double(episodes)
                addAttachment(string: suffix + " finished in \(steps) steps and \(episodes) episodes for \(stepsPerEpisode) steps/episode")
                iterationRecords.append(steps)
                iterationsPerEpisodeRecords.append(stepsPerEpisode)
            })
            
            XCTContext.runActivity(named: "Play policy for " + suffix, block: {_ in
                var score = 0.0
                var currentState = GridSquare(x: 0, y: 0)
                let plays = 1000
                let greedyPolicy = EpsilonGreedyPolicy(
                    actionsForStateDelegate: { environment.getActions(forState: $0) },
                    actionValueDelegate: { learner.getEstimate(forState: $0, action: $1) },
                    epsilon: 0.0)
                let trace = playGridWorld(gridWorld: gridWorld, withPolicy: greedyPolicy, currentState: &currentState, score: &score, plays: plays)
                addAttachment(string: "Score for " + suffix + " is \(score) after \(plays) plays")
                addAttachment(string: createGrid(mdp: gridWorld, policy: greedyPolicy))
                addAttachment(string: trace)
                scoreRecords.append(score)
            })

        }
        
        let inputsText = inputs.map({ "(\($0.discount), \($0.stepSize), \($0.epsilon))" }).joined(separator: ", ")
        let iterationsText = iterationRecords.map({ String($0) }).joined(separator: ", ")
        let iterationsPerEpisodeText = iterationsPerEpisodeRecords.map({ String($0) }).joined(separator: ", ")
        let totalValueText = scoreRecords.map({ String($0) }).joined(separator: ", ")
        let report = "Inputs: \(inputsText)\nIterations: \(iterationsText)\nIterations per episode: \(iterationsPerEpisodeText)\nTotals: \(totalValueText)"
        addAttachment(string: report)
    }
}
