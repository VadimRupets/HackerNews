//
//  StoriesOperation.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

class StoriesOperation: Operation {
    typealias ResponseObject = [Int]

    var request: Request

    init(request: StoriesRequests) {
        self.request = request
    }

    func execute(in discpatcher: Dispatcher, completionHandler: @escaping (([Int]?, Error?) -> ())) {
        guard Reachability.isReachable else {
            completionHandler(nil, NetworkError.noInternetConnection)
            return
        }

        do {
            try discpatcher.execute(request: request, completionHandler: { response in
                switch response {
                case .error(let error):
                    completionHandler(nil, error)
                case .data(let data):
                    let jsonDecoder = JSONDecoder()
                    do {
                        let stories = try jsonDecoder.decode([Int].self, from: data)
                        completionHandler(stories, nil)
                    } catch {
                        completionHandler(nil, error)
                    }
                }
            })
        } catch {
            completionHandler(nil, error)
        }
    }
}
