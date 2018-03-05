//
//  NetworkErrors.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case
    noInternetConnection,
    noData,
    badInput

    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "No Internet connection. Please check your internet connection and retry."
        case .noData:
            return "No data available."
        case .badInput:
            return "Cannot create URL for this address"
        }
    }
}
