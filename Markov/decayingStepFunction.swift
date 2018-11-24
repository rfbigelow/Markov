//
//  decayingStepFunction.swift
//  Markov
//
//  Created by Robert Bigelow on 11/23/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

class DecayingStepFunction<State: Hashable, Action: Hashable>: StepFunction {
    struct Key: Hashable {
        let state: State
        let action: Action
    }
    
    private var counts: Dictionary<Key, Int> = Dictionary()
    private let minStep: Double
    
    init(min: Double = 0.0) {
        minStep = min
    }
    
    func stepSize(_ s: State, _ a: Action) -> Double {
        let key = Key(state: s, action: a)
        var count = counts[key] ?? 0
        count += 1
        counts[key] = count
        return max(1.0 / Double(1 + count), minStep)
    }
}
