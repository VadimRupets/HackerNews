//
//  Response.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

public enum Response {
    case
    error(Error),
    data(Data)

    init(data: Data?, error: Error?) {
        guard error == nil else {
            self = .error(error!)
            return
        }

        guard let data = data else {
            self = .error(NetworkError.noData)
            return
        }

        self = .data(data)
    }
}
