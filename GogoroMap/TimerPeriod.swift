//
//  TimerPeriod.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2020/2/26.
//  Copyright © 2020 陳 冠禎. All rights reserved.
//

import Foundation

extension TimePeriod {
    init(effectiveDuration: TimeInterval = 5*60) {
        self.init(endDate: Date().addingTimeInterval(max(effectiveDuration, 0)))
    }
}

struct TimePeriod {
   
    let startDate: Date
    
    let endDate: Date
    
    let duration: TimeInterval
    
    private var expired: Bool = false
    
    var isExpired: Bool { return expired || Date() > endDate }
    
    mutating func expire() { expired = true }
    
    mutating func reset() {
        self = .init(effectiveDuration: endDate.timeIntervalSince(startDate))
    }
    
    init(startDate: Date = Date(), endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.duration = endDate.timeIntervalSince(startDate)
    }
}
