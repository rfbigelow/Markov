//
//  discreteDistribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// Forms the partial sum of the given sequence.
func partialSum(_ seq: [Double]) -> [Double] {
    var psum: [Double] = []
    var sum = 0.0
    for x in seq {
        sum += x
        psum.append(sum)
    }
    return psum
}

/// Errors that can be thrown by a DiscreteDistribution<T>
enum DiscreteDistributionError: Error {
    case badRandomValue(randomValue: Double, partialSum: [Double])
}

/// A discrete distribution of events.
struct DiscreteDistribution<T>: Distribution {
    
    let events: [T]
    let psum: [Double]
    
    /// Initialize the distribution with a sequence of tuples that look like (event, probability).
    init(weightedEvents: [(T, Double)]) {
        let totalWeight = weightedEvents.reduce(0.0, {(acc, arg1) -> Double in let (_, x) = arg1; return acc + x})
        assert(totalWeight - 1.0 <= Double.leastNonzeroMagnitude, "Total weight must be 1.0, but was \(totalWeight).")
        
        events = weightedEvents.map({(e: T, _: Double) -> T in return e})
        let weights = weightedEvents.map({_, x -> Double in return x})
        psum = partialSum(weights)
    }
    
    /// Gets the next event from the distribution.
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
