//
//  NetStakURLRequestTests.swift
//  NetStakTests
//
//  Created by Kent Franks on 3/21/19.
//  Copyright © 2019 KefBytes. All rights reserved.
//

import XCTest
import NetStak

class NetStakURLRequestTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreate() {
        XCTAssertNotNil(NetStakURLRequest.create(with: URL(string: "https://swapi.co/api")!, type: .get, headerFieldItems: ["":""]) as URLRequest)
    }


}
