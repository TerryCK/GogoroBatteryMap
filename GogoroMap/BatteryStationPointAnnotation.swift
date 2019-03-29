//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

extension BatteryStationPointAnnotation {
    public var iconImage: UIImage {
        guard checkinCounter ?? 0 <= 0 else { return #imageLiteral(resourceName: "checkin") }
        guard let name = title, state == 1 else { return #imageLiteral(resourceName: "building") }
        if name.contains("Gogoro")                                { return #imageLiteral(resourceName: "goStore") }
        if ["加油", "中油"].reduce(false, { $0 || name.contains($1) })   { return #imageLiteral(resourceName: "gasStation") }
        if ["家樂福", "大潤發", "Mall", "百貨", "Global Mall", "CITYLINK"].reduce(false, { $0 || name.contains($1) })     { return #imageLiteral(resourceName: "mallStore") }
        if ["HiLife", "全聯", "7-ELEVEN", "全家"].reduce(false, { $0 || name.contains($1) })  { return #imageLiteral(resourceName: "convenientStore") }
        return #imageLiteral(resourceName: "pinFull")
    }
    
    
    convenience init(_ customPointAnnotation: CustomPointAnnotation) {
        self.init(title         : customPointAnnotation.title,
                  subtitle      : customPointAnnotation.subtitle,
                  coordinate    : customPointAnnotation.coordinate,
                  address       : customPointAnnotation.address,
                  state         : customPointAnnotation.isOpening ? 1 : 0,
                  checkinCounter: customPointAnnotation.checkinCounter,
                  checkinDay    : customPointAnnotation.checkinDay)
    } 
}

protocol BatteryDataModal {
    var title: String? { get }
    var subtitle: String? { get }
    var coordinate: CLLocationCoordinate2D { get }
    var address: String { get }
    var state: Int { get }
    var checkinCounter: Int? { set get }
    var checkinDay: String? { set get }
    var iconImage: UIImage { get }
    func distance(from userPosition: CLLocation) -> Double
}

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

extension BatteryDataModal {
    func distance(from userPosition: CLLocation) -> Double {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: userPosition)
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(title: try container.decode(String?.self, forKey: .title),
                  subtitle: try container.decode(String?.self, forKey: .subtitle),
                  coordinate: try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate),
                  address: try container.decode(String.self, forKey: .address),
                  state:  try container.decode(Int.self, forKey: .state),
                  checkinCounter: try container.decode(Int?.self, forKey: .checkinCounter),
                  checkinDay: try container.decode(String?.self, forKey: .checkinDay))
    }
    
}

public final class BatteryStationPointAnnotation: MKPointAnnotation, BatteryDataModal {
    public let address: String, state: Int
    public var checkinCounter: Int? = nil, checkinDay: String? = nil
    
    public override func isEqual(_ object: Any?) -> Bool {
        return hashValue == (object as? BatteryStationPointAnnotation)?.hashValue
    }
    
    public override var hashValue: Int { return coordinate.hashValue }
    
    
    public convenience init<T: ResponseStationProtocol>(station: T) {
        self.init(title: station.name.localized() ?? "",
                  subtitle: "\("Open hours:".localize()) \(station.availableTime ?? "")",
            coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
            address: station.address.localized() ?? "",
            state: station.state)
    }
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, address: String, state: Int, checkinCounter: Int? = nil, checkinDay: String? = nil) {
        self.address      = address
        self.state    = state
        self.checkinCounter = checkinCounter
        self.checkinDay = checkinDay
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }
    
    
}

extension Array where Element: Hashable {    
    mutating func keepOldUpdate(with new: Array) {
        self = Array(Set<Element>(self).intersection(new).union(new))
    }
}


protocol Serializable: Encodable {
    func serialize() -> Data?
}

extension Serializable {
    func serialize() -> Data? {
        return try? JSONEncoder().encode(self)    }
}
