//
//  discreteDistribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// Forms the prefix sum of the given sequence.
func prefixSum(_ seq: [Double]) -> [Double] {
    return seq.reduce(into: []) { $0.append(($0.last ?? 0) + $1) }
}

/// Errors that can be thrown by a DiscreteDistribution<T>
enum DiscreteDistributionError: Error {
    case badRandomValue(randomValue: Double, partialSum: [Double])
}

/// A discrete distribution of events.
class DiscreteDistribution<T>: Distribution {
    
    var events: [T]
    let psum: [Double]
    let weights: [Double]
    
    /// Initialize the distribution with a sequence of tuples that look like (event, probability).
    init(weightedEvents: [(T, Double)]) {
        let totalWeight = weightedEvents.reduce(0.0, {(acc, arg1) -> Double in let (_, x) = arg1; return acc + x})
        assert(totalWeight - 1.0 <= Double.leastNonzeroMagnitude, "Total weight must be 1.0, but was \(totalWeight).")
        
        events = weightedEvents.map({(e: T, _: Double) -> T in return e})
        weights = weightedEvents.map({_, x -> Double in return x})
        psum = prefixSum(weights)
    }
    
    func getExpectedValue(withTransform t: (T) -> Double) -> Double {
        return zip(events, weights).map({t($0) * $1}).reduce(0, +)
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
    
    func getProbability(forEventMatchedBy isMatch:(T) -> Bool) -> Double {
        for (event, weight) in zip(events, weights) {
            if isMatch(event) {
                return weight
            }
        }
        return 0.0
    }
    
    func getEvent(matching isMatch:(T) -> Bool) -> T? {
        for event in events {
            if isMatch(event) {
                return event
            }
        }
        return nil
    }
}
