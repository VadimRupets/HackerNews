//
//  Collection+Extensions.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/6/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
