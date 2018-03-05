//
//  StoriesRequests.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

public enum StoriesRequests: Request {

    case
    newStories,
    topStories,
    bestStories

    public var path: String {
        switch self {
        case .newStories:
            return "/newstories.json"
        case .topStories:
            return "/topstories.json"
        case .bestStories:
            return "/beststories.json"
        }
    }

    public var method: HTTPMethod {
        return .get
    }

}
