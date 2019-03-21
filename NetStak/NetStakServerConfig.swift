//
//  NetStakServerConfig.swift
//  NetStak
//
//  Created by Kent Franks on 2/12/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public protocol NetStakServerConfigProtocol {
    var hostBase: String { get }
    var discoMode: Bool { get }
}

public struct NetStakServerConfig: NetStakServerConfigProtocol {
    
    // TODO: hostBase must be set to your value
    public var hostBase: String = "https://swapi.co/api"
    public var discoMode: Bool =  false
    
    public init() {
        discoMode = NetStakSession.discoMode
        switch NetStakSession.environment {
        case .dev:
            hostBase = "https://swapi.co/api"
        case .qa:
            hostBase = "https://swapi.co/api"
        case .uat:
            hostBase = "https://swapi.co/api"
        case .prod:
            hostBase = "https://swapi.co/api"
        }
    }
}
