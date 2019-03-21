//
//  NetStakServiceError.swift
//  NetStak
//
//  Created by Kent Franks on 2/13/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

enum NetStakServiceError: Error {
    case unbuildableURL
    case unableToInitResponseObject
    case unableToReadMockJson
}
