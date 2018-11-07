//
//  discreteDistribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

func partialSum(_ seq: [Double]) -> [Double] {
    var psum: [Double] = []
    var sum = 0.0
    for x in seq {
        sum += x
        psum.append(sum)
    }
    return psum
}

enum DiscreteDistributionError: Error {
    case badRandomValue(randomValue: Double, partialSum: [Double])
}

struct DiscreteDistribution<T>: Distribution {
    
    let events: [T]
    let psum: [Double]
    
    init(weightedEvents: [(T, Double)]) {
        let totalWeight = weightedEvents.reduce(0.0, {(acc, arg1) -> Double in let (_, x) = arg1; return acc + x})
        assert(totalWeight - 1.0 <= Double.leastNonzeroMagnitude, "Total weight must be 1.0, but was \(totalWeight).")
        
        events = weightedEvents.map({(e: T, _: Double) -> T in return e})
        let weights = weightedEvents.map({_, x -> Double in return x})
        psum = partialSum(weights)
    }
    
    func getNext() throws -> T {
        let rand = Double.random(in: 0...1)
        if let index = psum.firstIndex(where: {x -> Bool in rand <= x}) {
            return events[index]
        }
        else {
            throw DiscreteDistributionError.badRandomValue(randomValue: rand, partialSum: psum)
        }
    }
}
