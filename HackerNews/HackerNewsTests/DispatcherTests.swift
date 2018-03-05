//
//  DispatcherTests.swift
//  HackerNewsTests
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import XCTest
@testable import HackerNews

class DispatcherTests: XCTestCase {

    func testDispatcherReturnsBadInputErrorWhenRequestURLCannotBeCreated() {
        let completionExpectation = expectation(description: "Completion handler trigger")
        completionExpectation.isInverted = true

        // Given: Mocked dispatcher
        let dispatcher = MockDispatcher()

        // When: Dispatcher tries to execute request with invalid URL characters in request path
        let expectedError = NetworkError.badInput
        var receivedError: NetworkError?

        do {
            try dispatcher.execute(request: MockRequests.badInputRequest) { response in
                completionExpectation.fulfill()
            }
        } catch {
            receivedError = error as? NetworkError
        }

        // Then: Received error is equal to NetworkError.badInput
        wait(for: [completionExpectation], timeout: 1)
        XCTAssertEqual(expectedError, receivedError)
    }

    func testDispatcherReturnsNoErrorWithValidRequestURL() {
        let errorExpectation = expectation(description: "Error handler trigger")
        errorExpectation.isInverted = true

        let completionExpectation = expectation(description: "Completion handler trigger")

        // Given: Mocked dispatcher
        let dispatcher = MockDispatcher()

        // When: Dispatcher executes request with valid request path
        do {
            try dispatcher.execute(request: MockRequests.correctRequest, completionHandler: { response in
                switch response {
                case .data(_):
                    completionExpectation.fulfill()
                default:
                    break
                }
            })
        } catch {
            errorExpectation.fulfill()
        }

        // Then: Request is executed, catch closure is not triggered
        wait(for: [errorExpectation, completionExpectation], timeout: 1)
    }

}
