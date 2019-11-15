//
//  BatteryDataModalProtocol.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/7/8.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import MapKit
import UIKit

extension BatteryDataModalProtocol {
    
    var isOperating: Bool { return state == 1 && !(title?.contains("(維修中)") ?? true) }
    
    public var iconImage: UIImage {
        guard checkinCounter ?? 0 <= 0 else { return #imageLiteral(resourceName: "checkin") }
        guard let name = title, isOperating else { return #imageLiteral(resourceName: "building") }
        if name.contains("Gogoro")                                { return #imageLiteral(resourceName: "goStore") }
        if ["加油", "中油"].reduce(false, { $0 || name.contains($1) })   { return #imageLiteral(resourceName: "gasStation") }
        if ["家樂福", "大潤發", "Mall", "百貨", "Global Mall", "CITYLINK"].reduce(false, { $0 || name.contains($1) })     { return #imageLiteral(resourceName: "mallStore") }
        if ["HiLife", "全聯", "7-ELEVEN", "全家"].reduce(false, { $0 || name.contains($1) })  { return #imageLiteral(resourceName: "convenientStore") }
        if name.match(regex: "捷運".regex) { return #imageLiteral(resourceName: "MRT") }
        return #imageLiteral(resourceName: "pinFull")
    }
    func distance(from userPosition: CLLocation) -> CLLocationDistance {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: userPosition)
    }
}

protocol BatteryDataModalProtocol {
    
    var title: String? { get }
    var subtitle: String? { get }
    var coordinate: CLLocationCoordinate2D { get }
    var address: String { get }
    var state: Int { get }
    var checkinCounter: Int? { set get }
    var checkinDay: Date? { set get }
    var iconImage: UIImage { get }
    var isOperating: Bool { get }
    func distance(from userPosition: CLLocation) -> Double
}
