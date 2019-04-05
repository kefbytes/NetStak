//
//  NetStakURLHelper.swift
//  NetStak
//
//  Created by Kent Franks on 2/13/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

public struct NetStakURLHelper {
    
    public static func buildURL(with session: NetStakSession, request: NetStakRequestProtocol) -> URL? {
        let baseUrl: String = session.environment.baseURL()
        let endpoint: String = request.urlPath
        var args: String = ""
        if let urlArg = request.urlArguments {
            for (index, arg) in urlArg.enumerated() {
                switch index {
                case 0:
                    if let value = arg.value {
                        args += "?\(arg.name)=\(value)"
                    }
                default:
                    if let value = arg.value {
                        args += "&\(arg.name)=\(value)"
                    }
                }
            }
        }
        let urlString = baseUrl + endpoint + args
        return URL(string: urlString)
    }
    
}
