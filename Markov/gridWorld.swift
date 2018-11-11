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

enum GridAction { case up, down, left, right }

class GridWorld: TableDrivenMDP<GridAction, GridSquare> {
    typealias Action = GridAction
    typealias State = GridSquare
    
    let rowCount: Int
    let columnCount: Int
    
    init(rows: Int, columns: Int) {
        rowCount = rows
        columnCount = columns
        var grid = Dictionary<State, Dictionary<Action, DiscreteDistribution<Transition>>>()
        for i in 0..<columns {
            for j in 0..<rows {
                let gs = GridSquare(x: i, y: j)
                var moves = Dictionary<GridAction, DiscreteDistribution<Transition>>()
                moves[GridAction.up] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.up, rowCount: rows, columnCount: columns)
                moves[GridAction.down] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.down, rowCount: rows, columnCount: columns)
                moves[GridAction.left] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.left, rowCount: rows, columnCount: columns)
                moves[GridAction.right] = GridWorld.createMove(forGridSquare: gs, andAction: GridAction.right, rowCount: rows, columnCount: columns)
                grid[gs] = moves
            }
        }
        super.init(transitionTable: grid)
    }
    
    func addNexus(from: GridSquare, to: GridSquare, withReward reward: Reward) {
        var moves = Dictionary<GridAction, DiscreteDistribution<Transition>>()
        let transition = Transition(state: to, reward: reward)
        moves[GridAction.up] = DiscreteDistribution(weightedEvents: [(transition, 1.0)])
        moves[GridAction.down] = DiscreteDistribution(weightedEvents: [(transition, 1.0)])
        moves[GridAction.left] = DiscreteDistribution(weightedEvents: [(transition, 1.0)])
        moves[GridAction.right] = DiscreteDistribution(weightedEvents: [(transition, 1.0)])
        transitions[from] = moves
    }
    
    func addVortex(at: GridSquare, withReward reward: Reward) {
        updateAllRewards(forState: at, withReward: reward)
        transitions[at] = nil
    }
    
    private static func createMove(forGridSquare gs: GridSquare, andAction action: GridAction, rowCount: Int, columnCount: Int) -> DiscreteDistribution<Transition> {
        var transition: Transition
        switch action {
        case GridAction.up:
            if gs.y == rowCount - 1 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: -1.0)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y + 1), reward: 0.0)
            }
        case GridAction.down:
            if gs.y == 0 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: -1.0)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y - 1), reward: 0.0)
            }
        case GridAction.left:
            if gs.x == 0 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: -1.0)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x - 1, y: gs.y), reward: 0.0)
            }
        case GridAction.right:
            if gs.x == columnCount - 1 {
                transition = Transition(state: GridSquare(x: gs.x, y: gs.y), reward: -1.0)
            }
            else {
                transition = Transition(state: GridSquare(x: gs.x + 1, y: gs.y), reward: 0.0)
            }
        }
        return DiscreteDistribution(weightedEvents: [(transition, 1.0)])
    }
}
