//
//  NetStakSession.swift
//  NetStak
//
//  Created by Kent Franks on 2/19/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public enum NetStakEnvironment: String {
    case dev = "Dev"
    case qa = "QA"
    case uat = "UAT"
    case prod = "Prod"
}

public struct NetStakSession {
    public static var discoMode = false
    public static var environment: NetStakEnvironment = .dev
}
