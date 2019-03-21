//
//  NetStakRequestProtocol.swift
//  NetStak
//
//  Created by Kent Franks on 2/12/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public protocol NetStakRequestProtocol {
    
    var requestTypeMethod: NetStakHTTPMethod { get }
    var urlPath: String { get }
    var mockFileName: String { get }
    var urlArguments: [URLQueryItem]? { get }
    var headerItems: [String: String]? { get }
    var requestBody: Data? { get }
    var responseType: NetStakResponseProtocol.Type { get }
    var taskId: String { get }
    
}

public extension NetStakRequestProtocol {
    var taskId: String {
        get {
            return "dataTaskId.\(urlPath)"
        }
    }
}
