//
//  SegmentStatus.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit

enum SegmentStatus: Int, CaseIterable {
    case nearby = 0, checkin, uncheck, building
    
    
    var name: String {
        switch self {
        case .building  : return "即將啟用"
        case .nearby    : return "附近"
        case .checkin   : return "已打卡"
        case .uncheck   : return "未打卡"
        }
    }
    
    var eventName: String {
        return String(describing: self)
    }
    
    var hanlder: (BatteryDataModalProtocol) -> Bool {
        switch self {
        case .checkin       : return { $0.checkinCounter ?? 0 > 0 }
        case .uncheck       : return { $0.checkinCounter ?? 0 == 0 }
        case .nearby        : return { _ in true }
        case .building      : return { !$0.isOperating }
        }
    }
}

