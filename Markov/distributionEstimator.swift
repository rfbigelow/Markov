//
//  distributionEstimator.swift
//  Markov
//
//  Created by Robert Bigelow on 11/15/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

struct DistributionEstimator<T: Hashable>: Distribution {
    typealias Element = (T, Double)
    typealias Iterator = IndexingIterator<[(T, Double)]>.Iterator

    private var counts: Dictionary<T, Int>
    private var totalCount: Int
    
    mutating func addObservation(forEvent e: T, count: Int) {
        counts[e] = count + (counts[e] ?? 0)
        totalCount += count
    }
    
    /// Gets the expected value by transforming each event into a Double representing the event's value.
    func getExpectedValue(withTransform t: (T) -> Double) -> Double {
        return counts.map({ (t($0.key), Double($0.value)/Double(totalCount)) }).reduce(0.0, { $0 + $1.0 * $1.1 })
    }
    
    /// Gets the next event in the distribution, if there are any.
    func getNext() -> T? {
        let rand = Int.random(in: 0..<totalCount)
        var upper = 0
        for (event, count) in counts {
            upper += count
            if rand < upper {
                return event
            }
        }
        return nil
    }
    
    /// Gets the probability of the event e occurring.
    func getProbability(forEventMatchedBy isMatch:(T) -> Bool) -> Double {
        if let found = counts.keys.first(where: isMatch) {
            let count = counts[found]!
            return Double(count) / Double(totalCount)
        }
        return 0.0
    }
    
    /// Gets the event matching the given predicate, if a match is found.
    func getEvent(matching isMatch:(T) -> Bool) -> T? {
        return counts.keys.first(where: isMatch)
    }

    func makeIterator() -> Iterator {
        let events = counts.map( { ($0.key, Double($0.value)/Double(totalCount)) } )
        return events.makeIterator()
    }
}
