//
//  GogoroMapTests.swift
//  GogoroMapTests
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import XCTest
import MapKit
import CoreLocation
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
    
    func testBridge() {
        let image = UIImage(named: "pinFull")!
        let coordinate = CLLocationCoordinate2D(latitude: 100.0, longitude: 100.0)
        let placemark = MKPlacemark(coordinate: coordinate)
        
        let custom = [CustomPointAnnotation(title: "x", subtitle: "x", coordinate: coordinate, placemark: placemark, image: image, address: "x", isOpening: true)]

        let archiveData = NSKeyedArchiver.archivedData(withRootObject: custom)
//        let element = DataManager.shared.dataBridge(data: archiveData)?.first
        XCTAssert(element?.title == "x")
        XCTAssert(element! is BatteryStationPointAnnotation)
      
    }
}
