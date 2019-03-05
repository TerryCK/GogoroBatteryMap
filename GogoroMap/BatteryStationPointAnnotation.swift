//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

public final class BatteryStationPointAnnotation: MKPointAnnotation, Codable, Serializable {
    
    public let address: String, isOpening: Bool
    public var placemark: MKPlacemark { return MKPlacemark(coordinate: coordinate, addressDictionary: [title ?? "": ""]) }
    public var checkinCounter: Int? = nil, checkinDay: String? = nil
    
    public convenience init<T: ResponseStationProtocol>(station: T) {
        self.init(title: station.name.localized() ?? "",
                  subtitle: "\("Open hours:".localize()) \(station.availableTime ?? "")",
                  coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
                  address: station.address.localized() ?? "",
                  isOpening: station.isOpening)
    }
    
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, address: String, isOpening: Bool, checkinCounter: Int? = nil, checkinDay: String? = nil) {
        self.address      = address
        self.isOpening    = isOpening
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }
}

extension Array where Element: BatteryStationPointAnnotation {
    func merge(new: Array<Element>) -> Array<Element> {
        return Array(Set<Element>(self).intersection(new).union(new))
    }
}

protocol Serializable: Encodable {
    func serialize() -> Data?
}

extension Serializable {
    func serialize() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
