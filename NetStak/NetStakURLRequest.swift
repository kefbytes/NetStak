//
//  NetStakURLRequest.swift
//  NetStak
//
//  Created by Kent Franks on 2/15/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

struct NetStakURLRequest {
    
    // MARK: - URLRequest
    static func create(with url: URL, type: NetStakHTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.setValue(NetStakServiceConstants.applicationJsonValue, forHTTPHeaderField: NetStakServiceConstants.contentTypeKey)
        return request
    }
    
}