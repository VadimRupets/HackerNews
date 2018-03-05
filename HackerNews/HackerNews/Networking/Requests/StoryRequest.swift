//
//  StoryRequest.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

public enum StoryRequest: Request {
    case
    story(String)

    public var path: String {
        switch self {
        case .story(let storyId):
            return "item/\(storyId).json"
        }
    }

    public var method: HTTPMethod {
        return .get
    }

}
