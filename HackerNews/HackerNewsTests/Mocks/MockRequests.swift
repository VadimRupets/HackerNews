//
//  MockRequests.swift
//  HackerNewsTests
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

enum MockRequests: Request {
    case
    badInputRequest,
    correctRequest

    var path: String {
        switch self {
        case .badInputRequest:
            return "{||request-url||}"
        case .correctRequest:
            return "request-url"
        }
    }

    var method: HTTPMethod {
        return .get
    }
}
