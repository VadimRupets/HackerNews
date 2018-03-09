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
    
    func downloadIcon(from siteURL: URL, completionHandler: ((UIImage) -> ())) {
        guard
            let scheme = siteURL.scheme,
            let host = siteURL.host,
            let baseURL = URL(string: "\(scheme)://\(host)") else {
                completionHandler(#imageLiteral(resourceName: "placeholder"))
                return
        }
        
        guard let htmlSourceCode = try? String(contentsOf: siteURL) else {
            completionHandler(#imageLiteral(resourceName: "placeholder"))
            return
        }
        let tags = htmlSourceCode.split(separator: "<")
        
        var iconTag = tags.first(where: { tag in
            return tag.contains("rel=\"apple-touch-icon\"")
        })
        
        if iconTag == nil {
            iconTag = tags.first(where: { tag in
                return tag.contains("rel=\"icon\"") || tag.contains("rel=\"shortcut icon\"")
            })
        }
        
        guard
            var iconHref = iconTag?
                .components(separatedBy: "\" ")
                .first(where: { $0.contains("href") })?
                .components(separatedBy: "\"")[safe: 1] else {
                completionHandler(#imageLiteral(resourceName: "placeholder"))
                return
        }
        
        iconHref = iconHref.hasPrefix(".") ? String(iconHref.dropFirst()) : iconHref
        
        guard
            let percentEncodedIconHref = iconHref.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let iconURL = URL(string: percentEncodedIconHref, relativeTo: baseURL) else  {
            completionHandler(#imageLiteral(resourceName: "placeholder"))
            return
        }
        
        guard
            let iconData = try? Data(contentsOf: iconURL),
            let icon = UIImage(data: iconData) else {
                completionHandler(#imageLiteral(resourceName: "placeholder"))
                return
        }
        
        completionHandler(icon)
    }
    
}
