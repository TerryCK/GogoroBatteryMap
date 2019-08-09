//
//  LocationManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit
extension MKUserTrackingMode: CustomStringConvertible {
    var arrowImage: UIImage {
        switch self {
        case .none:              return #imageLiteral(resourceName: "locationArrowNone")
        case .follow:            return #imageLiteral(resourceName: "locationArrow")
        case .followWithHeading: return #imageLiteral(resourceName: "locationArrowFollewWithHeading")
        @unknown default: return #imageLiteral(resourceName: "locationArrowNone")
        }
    }
    
    public var description: String {
        switch self {
        case .none:              return "None"
        case .follow:            return "Follow"
        case .followWithHeading: return "Heading"
        @unknown default: return "None"
        }
    }
    
    public var nextMode: MKUserTrackingMode {
        return MKUserTrackingMode(rawValue: (rawValue + 1) % 3)!
    }
}
