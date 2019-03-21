//
//  NetStakURLHelperTests.swift
//  NetStakTests
//
//  Created by Kent Franks on 3/21/19.
//  Copyright © 2019 KefBytes. All rights reserved.
//

import XCTest
import NetStak

class NetStakURLHelperTests: XCTestCase {
    
    struct FetchCharactersResponse: NetStakResponseProtocol {
        var urlResponse: URLResponse?
        init(data: Data?, urlResponse: URLResponse?) throws {
        }
    }
    
    struct FetchCharactersRequest: NetStakRequestProtocol {
        var requestTypeMethod: NetStakHTTPMethod = .get
        var urlPath: String = "/people/"
        var mockFileName: String = "FetchCharacters"
        var urlArguments: [URLQueryItem]? = nil
        var headerItems: [String : String]? = nil
        var requestBody: Data? =  nil
        var responseType: NetStakResponseProtocol.Type = FetchCharactersResponse.self
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuildURL() {
        var serverConfig = NetStakServerConfig()
        serverConfig.discoMode = true
        serverConfig.hostBase = "https://swapi.co/api"
        let request = FetchCharactersRequest()
        XCTAssertNotNil(NetStakURLHelper.buildURL(with: serverConfig, request: request) as URL?)
        XCTAssertNotNil(NetStakURLHelper.buildURL(with: serverConfig, request: request)!)
    }

}
