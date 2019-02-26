//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

public protocol BatteryStationPointAnnotationProtocol: Hashable {
    func merge(newStations: [Self], oldStations: [Self]) -> [Self]
}

public extension BatteryStationPointAnnotationProtocol where Self: MKPointAnnotation {
    func merge(newStations: [Self], oldStations: [Self]) -> [Self] {
        return Array(Set<Self>(oldStations).intersection(newStations).union(newStations))
    }
}

public final class BatteryStationPointAnnotation: MKPointAnnotation, BatteryStationPointAnnotationProtocol {
    public let image: UIImage,
    placemark: MKPlacemark,
    address: String,
    isOpening: Bool
    
    public var checkinCounter: Int? = nil,
    checkinDay: String? = nil
    
    public init(station: ResponseStationProtocol) {
        let name     = station.name.localized() ?? ""
        let location = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
        placemark    = MKPlacemark(coordinate: location, addressDictionary: [name: ""])
        image        = station.annotationImage
        address      = station.address.localized() ?? ""
        isOpening    = station.isOpening
        super.init()
        title      = name
        subtitle   = "\("Open hours:") \(station.availableTime ?? "")"
        coordinate = location
    }
}
