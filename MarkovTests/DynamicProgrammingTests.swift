//
//  ValueIterationTests.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/24/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

class DynamicProgrammingTests: XCTestCase {
    struct TestInput {
        let tolerance: Double
        let discount: Double
    }
    
    let inputs: [TestInput] = [
        TestInput(tolerance: 0.001, discount: 0.7),
        TestInput(tolerance: 0.001, discount: 0.8),
        TestInput(tolerance: 0.001, discount: 0.9),
        TestInput(tolerance: 0.001, discount: 0.99),
        TestInput(tolerance: 0.01, discount: 0.7),
        TestInput(tolerance: 0.01, discount: 0.8),
        TestInput(tolerance: 0.01, discount: 0.9),
        TestInput(tolerance: 0.01, discount: 0.99)
        ]
    
    func testValueIterationSmallGrid() {
        let gridWorld = GridWorld(rows: 5, columns: 5, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.dig, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.dig, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.dig, withProbability: 0.005, withCost: -1.0)

        var iterationRecords = [Int]()
        var totalValueRecords = [Double]()
        for input in inputs {
            let suffix = "Tolerance: \(input.tolerance) Discount: \(input.discount)"
            var policy: StochasticPolicy<GridWorld> = StochasticPolicy(actionMap: Dictionary())
            var iterations = 0
            XCTContext.runActivity(named: "Get optimal policy with " + suffix, block: {_ in
                (policy, iterations) = ValueIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: input.tolerance, withDiscount: input.discount)
                addAttachment(string: suffix + " finished in \(iterations) iterations")
                addAttachment(string: createGrid(mdp: gridWorld, policy: policy))
                iterationRecords.append(iterations)
            })

            XCTContext.runActivity(named: "Evaluate policy for " + suffix, block: {_ in
                let evaluator = PolicyEvaluator(mdp: gridWorld, tolerance: input.tolerance, discount: input.discount)
                evaluator.evaluate(policy: policy)
                let totalValue = evaluator.estimates.values.reduce(0.0, +)
                addAttachment(string: "Total value for " + suffix + " is \(totalValue)")
                addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { evaluator.estimates[$0] ?? 0.0}, format: "%.2f"))
                totalValueRecords.append(totalValue)
            })
        }
        
        let inputsText = inputs.map({ "(\($0.tolerance), \($0.discount))" }).joined(separator: ", ")
        let iterationsText = iterationRecords.map({ String($0) }).joined(separator: ", ")
        let totalValueText = totalValueRecords.map({ String($0) }).joined(separator: ", ")
        let report = "Inputs: \(inputsText)\nIterations: \(iterationsText)\nTotals: \(totalValueText)"
        addAttachment(string: report)
    }
    
    func testValueIterationLargeGrid() {
        let gridWorld = GridWorld(rows: 25, columns: 25, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 24, y: 24), withReward: 0.0)

        var iterationRecords = [Int]()
        var totalValueRecords = [Double]()
        for input in inputs {
            let suffix = "Tolerance: \(input.tolerance) Discount: \(input.discount)"
            var policy: StochasticPolicy<GridWorld> = StochasticPolicy(actionMap: Dictionary())
            var iterations = 0
            XCTContext.runActivity(named: "Get optimal policy with " + suffix, block: {_ in
                (policy, iterations) = ValueIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: input.tolerance, withDiscount: input.discount)
                addAttachment(string: suffix + " finished in \(iterations) iterations")
                addAttachment(string: createGrid(mdp: gridWorld, policy: policy))
                iterationRecords.append(iterations)
            })
            
            XCTContext.runActivity(named: "Play policy for " + suffix, block: {_ in
                var score = 0.0
                var currentState = GridSquare(x: 0, y: 0)
                let plays = 1000
                let trace = playGridWorld(gridWorld: gridWorld, withPolicy: policy, currentState: &currentState, score: &score, plays: plays)
                addAttachment(string: "Score for " + suffix + " is \(score) after \(plays) plays")
                addAttachment(string: trace)
                totalValueRecords.append(score)
            })
        }
        
        let inputsText = inputs.map({ "(\($0.tolerance), \($0.discount))" }).joined(separator: ", ")
        let iterationsText = iterationRecords.map({ String($0) }).joined(separator: ", ")
        let totalValueText = totalValueRecords.map({ String($0) }).joined(separator: ", ")
        let report = "Inputs: \(inputsText)\nIterations: \(iterationsText)\nTotals: \(totalValueText)"
        addAttachment(string: report)
    }
    
    func testPolicyIterationSmallGrid() {
        let gridWorld = GridWorld(rows: 5, columns: 5, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 4, y: 4), withReward: 0.0)
        gridWorld.addStochasticReward(5.0, atGridSquare: GridSquare(x: 2, y: 2), forAction: GridAction.dig, withProbability: 0.2, withCost: -1.0)
        gridWorld.addStochasticReward(100.0, atGridSquare: GridSquare(x: 0, y: 4), forAction: GridAction.dig, withProbability: 0.01, withCost: -1.0)
        gridWorld.addStochasticReward(1000.0, atGridSquare: GridSquare(x: 4, y: 0), forAction: GridAction.dig, withProbability: 0.005, withCost: -1.0)
        
        var iterationRecords = [Int]()
        var totalValueRecords = [Double]()
        for input in inputs {
            let suffix = "Tolerance: \(input.tolerance) Discount: \(input.discount)"
            var policy: StochasticPolicy<GridWorld> = StochasticPolicy(actionMap: Dictionary())
            var iterations = 0
            var evalIterations = 0
            XCTContext.runActivity(named: "Get optimal policy with " + suffix, block: {_ in
                (policy, iterations, evalIterations) = PolicyIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: input.tolerance, withDiscount: input.discount)
                addAttachment(string: suffix + " finished in \(iterations) iterations plus \(evalIterations) evaluator iterations")
                addAttachment(string: createGrid(mdp: gridWorld, policy: policy))
                iterationRecords.append(evalIterations)
            })
            
            XCTContext.runActivity(named: "Evaluate policy for " + suffix, block: {_ in
                let evaluator = PolicyEvaluator(mdp: gridWorld, tolerance: input.tolerance, discount: input.discount)
                evaluator.evaluate(policy: policy)
                let totalValue = evaluator.estimates.values.reduce(0.0, +)
                addAttachment(string: "Total value for " + suffix + " is \(totalValue)")
                addAttachment(string: createGrid(mdp: gridWorld, withValueFunction: { evaluator.estimates[$0] ?? 0.0}, format: "%.2f"))
                totalValueRecords.append(totalValue)
            })
        }
        
        let inputsText = inputs.map({ "(\($0.tolerance), \($0.discount))" }).joined(separator: ", ")
        let iterationsText = iterationRecords.map({ String($0) }).joined(separator: ", ")
        let totalValueText = totalValueRecords.map({ String($0) }).joined(separator: ", ")
        let report = "Inputs: \(inputsText)\nIterations: \(iterationsText)\nTotals: \(totalValueText)"
        addAttachment(string: report)
    }

    func testPolicyIterationLargeGrid() {
        let gridWorld = GridWorld(rows: 25, columns: 25, movementCost: -1.0)
        gridWorld.addGoal(at: GridSquare(x: 24, y: 24), withReward: 0.0)

        var iterationRecords = [Int]()
        var totalValueRecords = [Double]()
        for input in inputs {
            let suffix = "Tolerance: \(input.tolerance) Discount: \(input.discount)"
            var policy: StochasticPolicy<GridWorld> = StochasticPolicy(actionMap: Dictionary())
            var iterations = 0
            var evalIterations = 0
            XCTContext.runActivity(named: "Get optimal policy with " + suffix, block: {_ in
                (policy, iterations, evalIterations) = PolicyIterator.getOptimalPolicy(forModel: gridWorld, withTolerance: input.tolerance, withDiscount: input.discount)
                addAttachment(string: suffix + " finished in \(iterations) iterations plus \(evalIterations) evaluator iterations")
                addAttachment(string: createGrid(mdp: gridWorld, policy: policy))
                iterationRecords.append(evalIterations)
            })
            
            XCTContext.runActivity(named: "Play policy for " + suffix, block: {_ in
                var score = 0.0
                var currentState = GridSquare(x: 0, y: 0)
                let plays = 1000
                let trace = playGridWorld(gridWorld: gridWorld, withPolicy: policy, currentState: &currentState, score: &score, plays: plays)
                addAttachment(string: "Score for " + suffix + " is \(score) after \(plays) plays")
                addAttachment(string: trace)
                totalValueRecords.append(score)
            })
        }
        
        let inputsText = inputs.map({ "(\($0.tolerance), \($0.discount))" }).joined(separator: ", ")
        let iterationsText = iterationRecords.map({ String($0) }).joined(separator: ", ")
        let totalValueText = totalValueRecords.map({ String($0) }).joined(separator: ", ")
        let report = "Inputs: \(inputsText)\nIterations: \(iterationsText)\nTotals: \(totalValueText)"
        addAttachment(string: report)
    }
}
