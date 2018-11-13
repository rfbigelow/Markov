//
//  binDistribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/12/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

/// A distribution that models a bin of objects, each equally likely to be drawn.
class BinDistribution<T>: Distribution {
    typealias Element = (T, Double)
    typealias Iterator = Zip2Sequence<[T], Repeated<Double>>.Iterator
    
    private let bin: [T]
    
    init(events: [T]) {
        bin = events
    }
    
    func getExpectedValue(withTransform t: (T) -> Double) -> Double {
        return bin.map(t).reduce(0.0, +) / Double(bin.count)
    }
    
    func getNext() -> T? {
        return bin.randomElement()
    }
    
    func getProbability(forEventMatchedBy isMatch: (T) -> Bool) -> Double {
        let matchCount = bin.filter(isMatch).count
        return Double(matchCount) / Double(bin.count)
    }
    
    func getEvent(matching isMatch: (T) -> Bool) -> T? {
        return bin.first(where: isMatch)
    }
    
    func makeIterator() -> Iterator {
        let weights = repeatElement(Double(1.0)/Double(bin.count), count: bin.count)
        return zip(bin, weights).makeIterator()
    }
}
