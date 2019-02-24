//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

final class BatteryStationPointAnnotation: MKPointAnnotation {
    let image: UIImage,
    placemark: MKPlacemark,
    checkinCounter: Int?,
    checkinDay: String?,
    address: String,
    isOpening: Bool
    
    init(station: ResponseStationProtocol) {
        let name     = station.name.localized() ?? ""
        let location = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
        placemark    = MKPlacemark(coordinate: location, addressDictionary: [name: ""])
        image        = station.annotationImage
        address      = station.address.localized() ?? ""
        isOpening    = station.isOpening
        checkinDay   = station.checkinDay
        checkinCounter = station.checkinCounter
        super.init()
        title      = name
        subtitle   = "\("Open hours:".localize()) \(station.availableTime ?? "")"
        coordinate = location
    }
}
