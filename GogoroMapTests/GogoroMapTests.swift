//
//  GogoroMapTests.swift
//  GogoroMapTests
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import XCTest

@testable import GogoroMap

class GogoroMapTests: XCTestCase {
    
    func testParseJSONObject() {
        guard let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json")  else {
             XCTFail("JSON file not found")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let response = try JSONDecoder().decode(Response.self, from: data)
            XCTAssertNotNil(response.stations.first?.address.localized())
        } catch {
           XCTFail("\(error)")
        }
    }
}
