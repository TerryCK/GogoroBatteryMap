//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

public final class BatteryStationPointAnnotation: MKPointAnnotation, Codable {
    public let address: String, state: Int
    public var checkinCounter: Int? = nil, checkinDay: String? = nil
   
    public var iconImage: UIImage {
        
        guard checkinCounter ?? 0 <= 0 else { return #imageLiteral(resourceName: "checkin") }
        guard let name = title, state == 1 else { return #imageLiteral(resourceName: "building") }
        if name.contains("Gogoro")                                { return #imageLiteral(resourceName: "goStore") }
        if ["加油", "中油"].reduce(false, { $0 || name.contains($1) })   { return #imageLiteral(resourceName: "gasStation") }
        if ["家樂福", "大潤發", "Mall", "百貨"].reduce(false, { $0 || name.contains($1) })     { return #imageLiteral(resourceName: "mallStore") }
        if ["HiLife", "全聯", "7-ELEVEN", "全家"].reduce(false, { $0 || name.contains($1) })  { return #imageLiteral(resourceName: "convenientStore") }
        return #imageLiteral(resourceName: "pinFull")
    }
    
    public convenience init<T: ResponseStationProtocol>(station: T) {
        self.init(title: station.name.localized() ?? "",
                  subtitle: "\("Open hours:".localize()) \(station.availableTime ?? "")",
            coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
            address: station.address.localized() ?? "",
            state: station.state)
    }

    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, address: String, state: Int, checkinCounter: Int? = nil, checkinDay: String? = nil) {
        self.address      = address
        self.state    = state
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }
}

extension Array where Element: Hashable {
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
