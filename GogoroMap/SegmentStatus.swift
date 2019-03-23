//
//  SegmentStatus.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit
import Crashlytics
import CoreLocation

enum SegmentStatus: Int {
    case map, checkin, nearby, building
    
    static let items: [SegmentStatus] = [map , checkin, nearby, building]
    
    var name: String {
        switch self {
        case .map       : return "地圖模式"
        case .building  : return "建置中列表"
        case .nearby    : return "附近列表"
        case .checkin   : return "打卡列表"
        }
    }
    
    var eventName: String {
        switch self {
        case .map       : return "Map mode"
        case .checkin   : return "Checkin list"
        case .nearby    : return "Nearby list"
        case .building  : return "Building list"
        }
    }
    
    func annotationsToDisplay<T: BatteryDataModal>(annotations: [T], currentUserLocation: CLLocation) -> [T] {
        
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons, customAttributes: [Log.sharedName.mapButton: eventName])
        
        let result: [T]?
        switch self {
        case .map       : result = nil
        case .checkin   : result = annotations.filter { $0.checkinCounter ?? 0 > 0 }
        case .nearby    : result = annotations.filter { $0.distance(from: currentUserLocation).km < 45 }
        case .building  : result = annotations.filter { $0.state != 1 }
        }
        
        return result?.sorted { $0.distance(from: currentUserLocation) < $1.distance(from: currentUserLocation) } ?? []
    }
}

