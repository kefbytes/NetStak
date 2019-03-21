//
//  NetStakMockJsonReader.swift
//  NetStak
//
//  Created by Kent Franks on 2/19/19.
//  Copyright © 2019 Kent Franks. All rights reserved.
//

import Foundation

let jsonFileType = "json"

public struct NetStakMockJsonReader {
    
    public static func readJson(with fileName: String) -> Data? {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: jsonFileType) else {
            return nil
        }
        guard let jsonData = FileManager.default.contents(atPath: filePath) else {
            return nil
        }
        return jsonData
    }
    
}
