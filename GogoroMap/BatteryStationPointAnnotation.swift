//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

extension CLLocationCoordinate2D: Codable {
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(latitude: try container.decode(CLLocationDegrees.self, forKey: .latitude),
                  longitude: try container.decode(CLLocationDegrees.self, forKey: .longitude))
    }
}


extension BatteryStationPointAnnotation : Codable {
    enum CodingKeys: String, CodingKey {
        case title, subtitle, coordinate, address, state, checkinCounter, checkinDay
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(address, forKey: .address)
        try container.encode(state, forKey: .state)
        try container.encode(checkinCounter, forKey: .checkinCounter)
        try container.encode(checkinDay, forKey: .checkinDay)
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container =             try decoder.container(keyedBy: CodingKeys.self)
        self.init(title:            try container.decode(String?.self, forKey: .title),
                  subtitle:         try container.decode(String?.self, forKey: .subtitle),
                  coordinate:       try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate),
                  address:          try container.decode(String.self, forKey: .address),
                  state:            try container.decode(Int.self, forKey: .state),
                  checkinCounter:   try container.decode(Int?.self, forKey: .checkinCounter),
                  checkinDay:       try container.decode(Date?.self, forKey: .checkinDay))
    }
}




public final class BatteryStationPointAnnotation: MKPointAnnotation, BatteryDataModalProtocol {
    public let address: String, state: Int
    public var checkinCounter: Int? = nil, checkinDay: Date? = nil
    public var city: String? = nil
    
    public override func isEqual(_ object: Any?) -> Bool {
        return coordinate.hashValue == (object as? BatteryStationPointAnnotation)?.coordinate.hashValue
    }
    
    public convenience init(station: Response.Station) {
        self.init(title: station.name.localized() ?? "",
                  subtitle: "\("Open hours:".localize()) \(station.availableTime ?? "")",
            coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
            address: station.address.localized() ?? "",
            state: station.state,
            city: station.city.localized())
    }
    
    private init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, address: String, state: Int, checkinCounter: Int? = nil, checkinDay: Date? = nil, city: String? = nil) {
        self.address      = address
        self.state    = state
        self.checkinCounter = checkinCounter
        self.checkinDay = checkinDay
        self.city = city
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }
}
