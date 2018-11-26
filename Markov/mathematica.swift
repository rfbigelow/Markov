//
//  mathematics.swift
//  Markov
//
//  Created by Robert Bigelow on 11/20/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

func createGrid<TModel: GridWorld, TPolicy: Policy>(mdp: TModel, policy: TPolicy) -> String where TModel.State == TPolicy.State, TModel.Action == TPolicy.Action {
    func createCell(actions: Set<TModel.Action>) -> String {
        var cell = "Graphics[{Arrowheads[Medium]"
        for action in actions {
            switch action {
            case GridAction.up:
                cell += ", up"
            case GridAction.down:
                cell += ", down"
            case GridAction.left:
                cell += ", left"
            case GridAction.right:
                cell += ", right"
            case GridAction.dig:
                cell += ", dig"
            }
        }
        cell += "}, PlotRange -> {{-1, 1}, {-1, 1}}, ImagePadding -> 10]"
        return cell
    }
    
    var grid = "GraphicsGrid[{"
    var firstRow = true
    
    for y in 1...mdp.rowCount {
        var row = "{"
        var firstCell = true
        for x in 0..<mdp.columnCount {
            let state = GridSquare(x: x, y: mdp.rowCount - y)
            if let actions = mdp.getActions(forState: state) {
                let policyActions = actions.filter({ policy.getProbability(fromState: state, ofTaking: $0) > 0.0 })
                
                if policyActions.isEmpty {
                    continue
                }
                
                if firstCell {
                    row += createCell(actions: policyActions)
                    firstCell = false
                }
                else {
                    row += ", " + createCell(actions: policyActions)
                }
            }
        }
        row += "}"
        if firstRow {
            grid += row
            firstRow = false
        }
        else {
            grid += ", " + row
        }
    }
    grid += "}, Frame -> All]"
        
    return grid
}

func createGrid<TModel: GridWorld>(mdp: TModel, withValueFunction v: (TModel.State) -> Reward, format: String) -> String {
    var grid = "Grid[{"
    var firstRow = true
    
    for y in 1...mdp.rowCount {
        var row = "{"
        var firstCell = true
        for x in 0..<mdp.columnCount {
            let state = GridSquare(x: x, y: mdp.rowCount - y)
            let reward = String(format: format, v(state))
            if firstCell {
                row += reward
                firstCell = false
            }
            else {
                row += ", " + reward
            }
        }
        row += "}"
        if firstRow {
            grid += row
            firstRow = false
        }
        else {
            grid += ", " + row
        }
    }
    grid += "}, Frame -> All]"
    
    return grid
}
