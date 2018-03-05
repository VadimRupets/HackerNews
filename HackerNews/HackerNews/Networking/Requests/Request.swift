//
//  Request.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

public protocol Request {

    var path: String { get }
    var method: HTTPMethod { get }

}
