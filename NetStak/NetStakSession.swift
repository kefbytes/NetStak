//
//  NetStakSession.swift
//  NetStak
//
//  Created by Kent Franks on 2/19/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public enum NetStakEnvironment: String {
    case dev = "https://swapi.co/api"
    case qa
    case uat
    case prod
    case mock
    
    func baseURL() -> String {
        let baseUrls = NetStakBaseUrls.shared
        switch self {
        case .dev:
            return baseUrls.dev ?? ""
        case .qa:
            return baseUrls.qa ?? ""
        case .uat:
            return baseUrls.uat ?? ""
        case .prod:
            return baseUrls.prod ?? ""
        case .mock:
            return ""
        }
    }
}

public class NetStakBaseUrls {
    public static let shared = NetStakBaseUrls()
    public var dev: String?
    public var qa: String?
    public var uat: String?
    public var prod: String?
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
