//
//  Dispatcher.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

public protocol Dispatcher {
    func execute(request: Request, completionHandler: @escaping ((Response) -> ())) throws
}

public class NetworkDispatcher: Dispatcher {

    private let host = "https://hacker-news.firebaseio.com/v0/"
    private let session = URLSession(configuration: .default)

    private func prepateURLRequest(with request: Request) throws -> URLRequest {
        guard let requestURL = URL.init(string: host + request.path) else {
            throw NetworkError.badInput
        }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = request.method.rawValue

        return urlRequest
    }

    public func execute(request: Request, completionHandler: @escaping ((Response) -> ())) throws {
        let urlRequest = try prepateURLRequest(with: request)
        
        let dataTask = session.dataTask(with: urlRequest) {
            completionHandler(Response.init(data: $0, error: $2))
        }
        
        dataTask.resume()
    }

}
