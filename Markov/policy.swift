//
//  policy.swift
//  Markov
//
//  Created by Robert Bigelow on 11/9/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

/// A policy determines which action to take for a given state.
protocol Policy {
    associatedtype State: Hashable
    associatedtype Action
    
    /// Gets an action for the given state, as determined by this policy.
    func getAction(forState state: State) -> Action
}
