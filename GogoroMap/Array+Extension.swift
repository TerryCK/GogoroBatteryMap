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
    
    func sorted(by order: (CLLocationDistance, CLLocationDistance) -> Bool) -> [Element] {
        guard let userLocation = LocationManager.shared.userLocation else { return Array(self) }
        return sorted { order($0.distance(from: userLocation), $1.distance(from: userLocation)) }
    }
}


extension Array where Element: BatteryDataModalProtocol {
    enum Strategy {
        case sync, remove
    }
    
    func keepOldUpdate(with other: Array) -> Array {
        for var new in other {
            for local in self where local == new {
                (new.checkinCounter, new.checkinDay) = (local.checkinCounter, local.checkinDay)
                break
            }
        }
        return other
    }
    
    mutating func update(_ operation: Strategy, _ target: Element) {
        switch operation {
        case .sync:
            if let index = firstIndex(where: { $0.coordinate == target.coordinate }) {
                self[index] = target
            } else if let index = firstIndex(where: { $0.distance > target.distance }) {
                insert(target, at: index)
            } else {
                append(target)
            }
            
        case .remove:
            if let index = firstIndex(where: { $0.coordinate == target.coordinate }) {
                remove(at: index)
            }
        }
    }
}
