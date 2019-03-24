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
        if ["家樂福", "大潤發", "Mall", "百貨"].reduce(false, { $0 || name.contains($1) })     { return #imageLiteral(resourceName: "mallStore") }
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

protocol BatteryDataModal: Codable {
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

extension BatteryDataModal {
    func distance(from userPosition: CLLocation) -> Double {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: userPosition)
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
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
    }
}

extension Array where Element: Hashable {
     func merge(new: Array) -> (add: Array, deprecated: Array) {
        let oldSet = Set<Element>(self), newSet = Set<Element>(new)
        let add = Array(newSet.subtracting(oldSet)), deprecated = Array(oldSet.subtracting(newSet))
        return (add, deprecated)
    }
}

extension Array where Element: MKAnnotation {
    mutating func remove(annotations: Array) {
        annotations.forEach {  remove(annotation: $0) }
    }
    
    mutating func remove(annotation: Element) {
        _ = map { $0.coordinate }.index(of: annotation.coordinate).map { remove(at: $0) }
    }
}

protocol Serializable: Encodable {
    func serialize() -> Data?
}

extension Serializable {
    func serialize() -> Data? {
        return try? JSONEncoder().encode(self)    }
}
