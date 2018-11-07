//
//  markovDecisionProcess.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

protocol MarkovDecisionProcess {
    associatedtype Action: Hashable
    associatedtype State: Hashable
    
    func getActions(forState state: State) -> Set<Action>?
    func getReward(forState state: State) -> Reward
    func transition(_ state: State, _ action: Action) -> State
}
