//
//  Reachability.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import SystemConfiguration

final public class Reachability {

    public static var isReachable: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        if  flags.contains(.reachable) ||
            flags.contains(.isWWAN) ||
            !flags.contains(.connectionRequired) ||
            (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)) && !flags.contains(.interventionRequired){
            return true
        }

        return false
    }

}
