//
//  distribution.swift
//  Markov
//
//  Created by Robert Bigelow on 11/6/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import Foundation

protocol Distribution {
    associatedtype T
    
    func getNext() throws -> T
}
