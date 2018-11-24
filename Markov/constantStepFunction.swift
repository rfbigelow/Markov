//
//  ConstantStepFunction.swift
//  Markov
//
//  Created by Robert Bigelow on 11/23/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

struct ConstantStepFunction<State: Hashable, Action: Hashable>: StepFunction {
    
    private let stepSize: Double
    
    init(stepSize: Double) {
        self.stepSize = stepSize
    }
    
    func stepSize(_ s: State, _ a: Action) -> Double {
        return stepSize
    }
}
