//
//  MockDispatcher.swift
//  HackerNewsTests
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

class MockDispatcher: Dispatcher {

    let host = "https://example.com"

    private func prepateURLRequest(with request: Request) throws -> URLRequest {
        guard let requestURL = URL(string: host + request.path) else {
            throw NetworkError.badInput
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = request.method.rawValue

        return urlRequest
    }

    func execute(request: Request, completionHandler: @escaping ((Response) -> ())) throws {
        let _ = try prepateURLRequest(with: request)
        completionHandler(.data(Data()))
    }

}
