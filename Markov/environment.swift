//
//  Environment.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

protocol Environment {
    associatedtype Action: Hashable
    associatedtype State
    
    func select(action: Action) -> (Reward, State)
}
