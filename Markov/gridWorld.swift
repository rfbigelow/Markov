//
//  gridWorld.swift
//  Markov
//
//  Created by Robert Bigelow on 11/10/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

struct GridSquare: Equatable, Hashable {
    let x: Int
    let y: Int
}

enum GridAction { case up, down, left, right, engageClaw }

class GridWorld: TableDrivenMDP<GridAction, GridSquare> {
    typealias Action = GridAction
    typealias State = GridSquare
    
    let rowCount: Int
    let columnCount: Int
    
    init(rows: Int, columns: Int, movementCost: Double = -1.0, wallPenalty: Double = -1.0) {
        rowCount = rows
        columnCount = columns
        var grid = Dictionary<State, Dictionary<Action, WeightedDistribution<Transition<State>>>>()
        for i in 0..<columns {
            for j in 0..<rows {
                let gs = GridSquare(x: i, y: j)
                var moves = Dictionary<GridAction, WeightedDistribution<Transition<State>>>()
                moves[GridAction.up] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.up,
                                                            rowCount: rows, columnCount: columns,
                                                            movementCost: movementCost, wallPenalty: wallPenalty)
                moves[GridAction.down] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.down,
                                                              rowCount: rows, columnCount: columns,
                                                              movementCost: movementCost, wallPenalty: wallPenalty)
                moves[GridAction.left] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.left,
                                                              rowCount: rows, columnCount: columns,
                                                              movementCost: movementCost, wallPenalty: wallPenalty)
                moves[GridAction.right] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.right,
                                                               rowCount: rows, columnCount: columns,
                                                               movementCost: movementCost, wallPenalty: wallPenalty)
                grid[gs] = moves
            }
        }
        super.init(transitionTable: grid)
    }
    
    func addNexus(from: GridSquare, to: GridSquare, withReward reward: Reward) {
        var moves = Dictionary<GridAction, WeightedDistribution<Transition<State>>>()
        let transition = Transition(state: to, reward: reward)
        moves[GridAction.up] = WeightedDistribution(weightedEvents: [(transition, 1.0)])
        moves[GridAction.down] = WeightedDistribution(weightedEvents: [(transition, 1.0)])
        moves[GridAction.left] = WeightedDistribution(weightedEvents: [(transition, 1.0)])
        moves[GridAction.right] = WeightedDistribution(weightedEvents: [(transition, 1.0)])
        transitions[from] = moves
    }
    
    func addGoal(at: GridSquare, withReward reward: Reward) {
        updateAllRewards(forState: at, withReward: reward)
        transitions[at] = nil
    }
    
    func addStochasticReward(_ reward: Reward, atGridSquare gs: GridSquare, forAction action: GridAction, withProbability p: Double, withCost cost: Reward) {
        assert(p > 0.0 && p < 1.0)
        let distribution = WeightedDistribution(weightedEvents: [(Transition(state: gs, reward: reward), p), (Transition(state: gs, reward: cost), 1.0 - p)])
        var moves = transitions[gs] ?? Dictionary()
        moves[action] = distribution
        transitions[gs] = moves
    }
    
    private static func createMove(forGridSquare gs: GridSquare,
                                   andAction action: GridAction,
                                   rowCount: Int,
                                   columnCount: Int,
                                   movementCost: Double,
                                   wallPenalty: Double) -> WeightedDistribution<Transition<State>>? {
        var transition: Transition<State>
        switch action {
        case GridAction.up:
            if gs.y == rowCount - 1 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: wallPenalty)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y + 1), reward: movementCost)
            }
        case GridAction.down:
            if gs.y == 0 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: wallPenalty)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y - 1), reward: movementCost)
            }
        case GridAction.left:
            if gs.x == 0 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: wallPenalty)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x - 1, y: gs.y), reward: movementCost)
            }
        case GridAction.right:
            if gs.x == columnCount - 1 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: wallPenalty)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x + 1, y: gs.y), reward: movementCost)
            }
        case GridAction.engageClaw:
            return nil
        }
        return WeightedDistribution(weightedEvents: [(transition, 1.0)])
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
