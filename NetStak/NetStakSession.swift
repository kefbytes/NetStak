//
//  NetStakSession.swift
//  NetStak
//
//  Created by Kent Franks on 2/19/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

#warning("Set your environment host base values")
public enum NetStakEnvironment: String {
    case dev = "https://swapi.co/api"
    case qa
    case uat
    case prod
    case mock
}

public class NetStakSession {
    public static let shared = NetStakSession()
    public let defaultSession: URLSession
    public var environment: NetStakEnvironment
    public var activeDataTasks: [String: URLSessionDataTask] = [:]
    private init() {
        self.defaultSession = URLSession(configuration: .default)
        self.environment = .dev
    }
}
