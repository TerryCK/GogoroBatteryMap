//
//  Array+Extension.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2019/8/9.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import MapKit

extension Collection where Element: BatteryStationPointAnnotation {
    
    func filter(text searchText: String) -> [Element] {
        guard !searchText.isEmpty else { return Array(self)  }
        let keywords = searchText.replacingOccurrences(regex: "臺".regex, replacement: "台").regex
        return filter {
            $0.address.match(regex: keywords)
                || $0.title?.match(regex: keywords) ?? false
                || ("建置中|即將啟用".match(regex: keywords) && !$0.isOperating)
                || ("打卡|checkin".match(regex: keywords) && $0.checkinDay != nil)
                || ("便利商店".match(regex: keywords) && ($0.title ?? "").match(regex: "HiLife|全聯|7-ELEVEN|全家".regex))
                || (keywords.pattern.match(regex: "7?.11?".regex) && ($0.title ?? "").match(regex: "7-ELEVEN".regex))
        }
    }
    
    func sorted(userLocation: CLLocation?, by order: (CLLocationDistance, CLLocationDistance) -> Bool) -> [Element] {
        guard let userLocation = userLocation else { return Array(self) }
        return sorted { order($0.distance(from: userLocation), $1.distance(from: userLocation)) }
    }
}
