//
//  StoryOperation.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

class StoryOperation: Operation {
    typealias ResponseObject = Story

    let storyId: String

    var request: Request {
        return StoryRequest.story(storyId)
    }

    init(storyId: String) {
        self.storyId = storyId
    }

    func execute(in discpatcher: Dispatcher, completionHandler: @escaping ((Story?, Error?) -> ())) {
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
                        let story = try jsonDecoder.decode(Story.self, from: data)
                        completionHandler(story, nil)
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
