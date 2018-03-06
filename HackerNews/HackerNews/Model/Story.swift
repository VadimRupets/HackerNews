//
//  Story.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

struct Story: Decodable {
    let id: Int
    let isDeleted: Bool?
    let isDead: Bool?
    let url: URL
    let title: String

    private enum CodingKeys: String, CodingKey {
        case
        id,
        isDeleted = "deleted",
        isDead = "dead",
        url,
        title
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)

        let isDeletedString = (try? values.decode(String.self, forKey: .isDeleted)) ?? ""
        isDeleted = Bool(isDeletedString)

        let isDeadString = (try? values.decode(String.self, forKey: .isDead)) ?? ""
        isDead = Bool(isDeadString)

        var urlString = try values.decode(String.self, forKey: .url)
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.url, in: values, debugDescription: "Cannot decode received URL")
        }
        self.url = url

        title = try values.decode(String.self, forKey: .title)
    }

}
