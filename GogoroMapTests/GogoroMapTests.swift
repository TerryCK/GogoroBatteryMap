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
            let batteryStation = try JSONDecoder().decode(BatteryStation.self, from: data)
            XCTAssertNotNil(batteryStation.data.first?.address.zh)
        } catch {
           XCTFail("\(error)")
        }
    }
}
