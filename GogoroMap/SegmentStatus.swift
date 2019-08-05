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

enum SegmentStatus: Int, CaseIterable {
    case map = 0, checkin, nearby, building
    
    
    var name: String {
        switch self {
        case .map       : return "地圖模式"
        case .building  : return "即將啟用"
        case .nearby    : return "附近列表"
        case .checkin   : return "打卡列表"
        }
    }
    
    var eventName: String {
        switch self {
        case .map       : return "Map mode"
        case .checkin   : return "Checkin"
        case .nearby    : return "Nearby"
        case .building  : return "Building"
        }
    }
    var hanlder: (BatteryDataModalProtocol) -> Bool {
        switch self {
        case .checkin       : return { $0.checkinCounter ?? 0 > 0 }
        case .nearby, .map  : return  { _ in true }
        case .building      : return{ !$0.isOperating }
        }
    }
    func annotationsToDisplay<T: BatteryDataModalProtocol>(annotations: [T], currentUserLocation: CLLocation) -> [T] {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons, customAttributes: [Log.sharedName.mapButton: eventName])
        let operating: (T) -> Bool
        
        switch self {
        case .map       : return []
        case .checkin   : operating =  { $0.checkinCounter ?? 0 > 0 }
        case .nearby    : operating =  { _ in true }
        case .building  : operating =  { !$0.isOperating }
        }
        
        return annotations
            .filter(operating)
            .sorted { $0.distance(from: currentUserLocation) < $1.distance(from: currentUserLocation) }
    }
}

