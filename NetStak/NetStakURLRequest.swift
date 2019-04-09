//
//  NetStakURLRequest.swift
//  NetStak
//
//  Created by Kent Franks on 2/15/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public struct NetStakURLRequest {
    
    // MARK: - URLRequest
    public static func create(with url: URL, type: NetStakHTTPMethod, headerFieldItems: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        if let headerItems = headerFieldItems {
            for item in headerItems {
                request.addValue(item.value, forHTTPHeaderField: item.key)
            }
        }
        return request
    }
    
}
