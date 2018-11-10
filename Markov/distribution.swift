//
//  distribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// A type representing a distribution of a random variable.
protocol Distribution {
    associatedtype T
    
    func getExpectedValue(withTransform t: (T) -> Double) -> Double
    
    /// Gets the next event in the distribution.
    func getNext() throws -> T
}
