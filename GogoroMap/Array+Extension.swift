//
//  Array+Extension.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2019/8/9.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import MapKit
extension Array where Element: BatteryStationPointAnnotation {
    func filter(text searchText: String) -> Array {
        guard !searchText.isEmpty else {
            return self
        }
        let keywords = searchText.replacingOccurrences(regex: "臺".regex, replacement: "台").regex
        return filter {
            $0.address.match(regex: keywords) ||
                $0.title?.match(regex: keywords) ?? false ||
                ("建置中||即將啟用".match(regex: keywords) && !$0.isOperating)
        }
    }
    
    func sorted(userLocation: CLLocation?, by order: (CLLocationDistance, CLLocationDistance) -> Bool) -> Array {
        guard let userLocation = userLocation else { return self }
        return sorted { order($0.distance(from: userLocation), $1.distance(from: userLocation)) }
    }
}
