//
//  stepFunction.swift
//  Markov
//
//  Created by Robert Bigelow on 11/23/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

protocol StepFunction {
    associatedtype State: Hashable
    associatedtype Action

    func stepSize(_ s: State, _ a: Action) -> Double
}
