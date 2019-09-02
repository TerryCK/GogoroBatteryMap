//
//  GoShareDataModel.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2019/8/31.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import MapKit
struct GoShareDataModel: Codable {
    let id, plate, lat, lng, soc, remainingMileage, socLevel, modelCode: String
    var coordinate: CLLocationCoordinate2D? {
        switch (Double(lat), Double(lng)) {
        case let (lat?, lng?): return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        default: return nil
        }
    }
}
public final class GoSharePointAnnotation: MKPointAnnotation {
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }
}
