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
    
    private func logWithAnswer() {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: eventName])
    }
    
    func getAnnotationToDisplay(annotations: [CustomPointAnnotation],
                                currentUserLocation: CLLocation) -> [CustomPointAnnotation]? {
        
        logWithAnswer()
        
        switch self {
        case .map: return nil
        case .checkin:
            return annotations.filter { $0.checkinCounter > 0 }
                .sortedByDistance(userPosition: currentUserLocation)
            
        case .nearby:
            return annotations.sortedByDistance(userPosition: currentUserLocation)
                .filter { $0.getDistance(from: currentUserLocation).km < 45 }
            
        case .building:
            return annotations.filter { !$0.isOpening }
                .sortedByDistance(userPosition: currentUserLocation)
        }
    }
    
}
