//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

public final class BatteryStationPointAnnotation: MKPointAnnotation {
    
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
    
//    enum CodingKeys: String, CodingKey {
//        case title, subtitle, coordinate, address, isOpening, checkinCounter, checkinDay, latitude, longitude
//    }
//
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, address: String, isOpening: Bool, checkinCounter: Int? = nil, checkinDay: String? = nil) {
        self.address      = address
        self.isOpening    = isOpening
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }

//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        address = try container.decode(String.self, forKey: .address)
//        isOpening = try container.decode(Bool.self, forKey: .isOpening)
//        checkinCounter = try container.decode(Int?.self, forKey: .checkinCounter)
//        checkinDay = try container.decode(String?.self, forKey: .checkinDay)
//        let latitude = try container.decode(Double.self, forKey: .latitude)
//        let longitude = try container.decode(Double.self, forKey: .longitude)
//        super.init()
//        title = try container.decode(String.self, forKey: .title)
//        subtitle = try container.decode(String.self, forKey: .subtitle)
//        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(title, forKey: .title)
//        try container.encode(subtitle, forKey: .subtitle)
//        try container.encode(coordinate.latitude, forKey: .latitude)
//        try container.encode(coordinate.longitude, forKey: .longitude)
//        try container.encode(address, forKey: .address)
//        try container.encode(isOpening, forKey: .isOpening)
//        try container.encode(checkinCounter, forKey: .checkinCounter)
//        try container.encode(checkinDay, forKey: .checkinDay)
//    }
    
    
    
//    required public convenience init?(coder aDecoder: NSCoder) {
//        self.init(title: aDecoder.decodeObject(forKey: CodingKeys.title.rawValue) as? String ?? "",
//                  subtitle: aDecoder.decodeObject(forKey: CodingKeys.subtitle.rawValue) as? String ?? "",
//                  coordinate: CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: CodingKeys.latitude.rawValue),
//                                                     longitude: aDecoder.decodeDouble(forKey: CodingKeys.longitude.rawValue)),
//                  address: aDecoder.decodeObject(forKey: CodingKeys.address.rawValue) as? String ?? "",
//                  isOpening: aDecoder.decodeBool(forKey: CodingKeys.isOpening.rawValue),
//                  checkinCounter: aDecoder.decodeInteger(forKey: CodingKeys.checkinCounter.rawValue),
//                  checkinDay: aDecoder.decodeObject(forKey: CodingKeys.checkinDay.rawValue) as? String ?? "")
//    }
//
  
//    public func encode(with aCoder: NSCoder) {
//        aCoder.encode(address, forKey: CodingKeys.address.rawValue)
//        aCoder.encode(isOpening, forKey: CodingKeys.isOpening.rawValue)
//        aCoder.encode(checkinCounter, forKey: CodingKeys.checkinCounter.rawValue)
//        aCoder.encode(checkinDay, forKey: CodingKeys.checkinDay.rawValue)
//        aCoder.encode(title, forKey: CodingKeys.title.rawValue)
//        aCoder.encode(subtitle, forKey: CodingKeys.subtitle.rawValue)
//        aCoder.encode(coordinate.latitude, forKey: CodingKeys.latitude.rawValue)
//        aCoder.encode(coordinate.longitude, forKey: CodingKeys.longitude.rawValue)
//    }
    
}

extension Array where Element: BatteryStationPointAnnotation {
    func merge(new: Array<Element>) -> Array<Element> {
        return Array(Set<Element>(self).intersection(new).union(new))
    }
}
