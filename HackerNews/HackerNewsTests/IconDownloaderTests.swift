//
//  IconDownloaderTests.swift
//  HackerNewsTests
//
//  Created by Vadim Rupets on 3/7/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import XCTest
@testable import HackerNews

class IconDowloaderTests: XCTestCase {
    
    func testIconDownloaderReturnsPlaceholderIconWhenProvidedURLIsInvalid() {
        let placeholderExpectation = expectation(description: "Icon downloader returns placeholder icon")
        let placeholderImageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder"))!
        
        // Given: Invalid URL
        let url = URL(string: "hello.world")!
        
        // When: IconDowloader tries to download favicon using given URL
        IconDownloader().downloadIcon(from: url) { icon in
            let downloadedImageData = UIImagePNGRepresentation(icon)!
            if downloadedImageData == placeholderImageData {
                placeholderExpectation.fulfill()
            }
        }
        
        // Then: IconDownloader returns placeholder icon
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testIconDownloaderReturnsDifferentIconWhenProvidedURLIsValidAndSiteContainsIcon() {
        let successExpectation = expectation(description: "Icon downloader returns different icon")
        let placeholderImageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder"))!
        
        // Given: valid URL with favicon
        let url = URL(string: "https://youtube.com")!
        
        // When: IconDowloader tries to download favicon using given URL
        IconDownloader().downloadIcon(from: url) { icon in
            let downloadedImageData = UIImagePNGRepresentation(icon)!
            if downloadedImageData != placeholderImageData {
                successExpectation.fulfill()
            }
        }
        
        // Then: IconDownloader returns different icon
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testIconDownloaderReturnsPlaceholderIconWhenProvidedURLIsValidAndSiteDoesNotContainIcon() {
        let placeholderExpectation = expectation(description: "Icon downloader returns placeholder icon")
        let placeholderImageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "placeholder"))!
        
        // Given: Valid site URL
        let url = URL(string: "http://deepideas.net")!
        
        // When: IconDowloader tries to download favicon using given URL
        IconDownloader().downloadIcon(from: url) { icon in
            let downloadedImageData = UIImagePNGRepresentation(icon)!
            if downloadedImageData == placeholderImageData {
                placeholderExpectation.fulfill()
            }
        }
        
        // Then: IconDownloader returns placeholder icon
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
