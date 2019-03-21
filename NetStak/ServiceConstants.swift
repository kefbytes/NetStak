//
//  ServiceConstants.swift
//  NetStak
//
//  Created by Kent Franks on 2/15/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get
    case post
    case put
}

struct ServiceConstants {
    static let applicationJsonValue = "Application/json"
    static let contentTypeKey = "Content-Type"
}
