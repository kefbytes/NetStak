//
//  ServiceError.swift
//  NetStak
//
//  Created by Kent Franks on 2/13/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case unbuildableURL
    case unableToInitResponseObject
    case unableToReadMockJson
}
