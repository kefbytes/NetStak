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

// TODO: hostBase must be set to your value
public struct NetStakServerConfig: NetStakServerConfigProtocol {
    
    #warning("NetStak: Set the hostBase default value")
    public var hostBase: String = ""
    public var discoMode: Bool =  false
    
    #warning("NetStak: Set the hostBase for each environment")
    public init() {
        discoMode = NetStakSession.discoMode
        switch NetStakSession.environment {
        case .dev:
            hostBase = ""
        case .qa:
            hostBase = ""
        case .uat:
            hostBase = ""
        case .prod:
            hostBase = ""
        }
    }
}
