//
//  Operation.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import Foundation

protocol Operation {
    associatedtype ResponseObject

    var request: Request { get }
    
    func execute(in discpatcher: Dispatcher, completionHandler: @escaping ((ResponseObject?, Error?) -> ()))
}
