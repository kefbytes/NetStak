//
//  URLRequestBuilder.swift
//  NetStak
//
//  Created by Kent Franks on 2/15/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

struct URLRequestBuilder {
    
    // MARK: - URLRequest
    static func create(with url: URL, type: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.setValue(ServiceConstants.applicationJsonValue, forHTTPHeaderField: ServiceConstants.contentTypeKey)
        return request
    }
    
}
