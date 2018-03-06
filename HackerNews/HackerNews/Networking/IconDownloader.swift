//
//  IconDownloader.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/6/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation
import UIKit

class IconDownloader {

    func downloadIcon(from siteURL: URL, completionHandler: ((UIImage) -> ())) throws {
        guard
            let scheme = siteURL.scheme,
            let host = siteURL.host,
            let baseURL = URL(string: "\(scheme)://\(host)") else { throw NetworkError.badInput }
        
        let htmlSourceCode = try String.init(contentsOf: siteURL)
        let tags = htmlSourceCode.split(separator: "<")
        
        let iconTag: Substring?
        
        if let appleTouchIconTag = tags.first(where: { $0.contains("apple-touch-icon") }) {
            iconTag = appleTouchIconTag
        } else if let faviconTag = tags.first(where: { $0.contains("favicon") }) {
            iconTag = faviconTag
        } else {
            throw NetworkError.noData
        }
        
        guard
            let iconHref = iconTag?
                .split(separator: " ")
                .first(where: { $0.contains("href") })?
                .components(separatedBy: "\"")[safe: 1],
            let iconURL = URL.init(string: iconHref, relativeTo: baseURL) else {
                throw NetworkError.noData
        }
        
        let iconData = try Data(contentsOf: iconURL)
        guard let icon = UIImage.init(data: iconData) else { throw NetworkError.noData }
        
        completionHandler(icon)
    }
    
}
