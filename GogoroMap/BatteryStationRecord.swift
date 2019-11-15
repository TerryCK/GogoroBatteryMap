//
//  BatteryStationRecord.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/7/8.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import MapKit
struct BatteryStationRecord: Codable {
   
    let id: CLLocationCoordinate2D, checkinCount: Int, checkinDay: Date?
}

extension BatteryStationRecord {
    
    init?(_ batteryModel: BatteryStationPointAnnotation) {
        guard let count = batteryModel.checkinCounter else { return nil }
        self.init(id: batteryModel.coordinate, checkinCount: count, checkinDay: batteryModel.checkinDay)
    }
}
