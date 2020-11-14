//
//  ReachabilityManager.swift
//  NetworkManagerDemo
//
//  Created by Honey Maheshwari on 02/06/20.
//  Copyright © 2020 Honey Maheshwari. All rights reserved.
//

import UIKit
import Reachability

protocol ReachabilityManagerDelegate: NSObjectProtocol {
    func networkStatusDidChnaged(_ isReachable: Bool)
}

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    private let reachability = try! Reachability()
    
    var isReachable: Bool!
    weak var delegate: ReachabilityManagerDelegate?
    
    override init() {
        super.init()
        isReachable = reachability.connection != .unavailable
    }
    
    func startListening() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            self.isReachable = true
            self.delegate?.networkStatusDidChnaged(true)
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.isReachable = false
            self.delegate?.networkStatusDidChnaged(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func stopListening() {
        reachability.stopNotifier()
    }
    
}
