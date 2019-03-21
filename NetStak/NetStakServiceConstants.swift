//
//  NetStakServiceConstants.swift
//  NetStak
//
//  Created by Kent Franks on 2/15/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public enum NetStakHTTPMethod: String {
    case get
    case post
    case put
}

struct NetStakServiceConstants {
    static let applicationJsonValue = "Application/json"
    static let contentTypeKey = "Content-Type"
}
