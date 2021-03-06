//
//  weightedDistribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// Errors that can be thrown by a WeightedDistribution<T>
enum WeightedDistributionError: Error {
    case badRandomValue(randomValue: Double, partialSum: [Double])
}

/// A discrete distribution of events.
class WeightedDistribution<T>: Distribution {
    typealias Element = (T, Double)
    typealias Iterator = Zip2Sequence<Array<T>, Array<Double>>.Iterator
    
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
    
    func getNext() -> T? {
        let rand = Double.random(in: 0...1)
        if let index = psum.firstIndex(where: {x -> Bool in rand <= x}) {
            return events[index]
        }
        else {
            return nil
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
    
    func makeIterator() -> WeightedDistribution<T>.Iterator {
        return zip(events, weights).makeIterator()
    }
}
