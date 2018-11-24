//
//  Extensions.swift
//  MarkovTests
//
//  Created by Robert Bigelow on 11/24/18.
//  Copyright © 2018 Robert Bigelow. All rights reserved.
//

import XCTest

extension XCTActivity {
    func addAttachment(string: String) {
        let attachment = XCTAttachment(string: string)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
