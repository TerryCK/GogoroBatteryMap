//
//  BatteryStationPointAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

public final class BatteryStationPointAnnotation: MKPointAnnotation, NSCoding {
    public let image: UIImage,
    placemark: MKPlacemark,
    address: String,
    isOpening: Bool
    
    public var checkinCounter: Int? = nil,
    checkinDay: String? = nil
    
    public convenience init(station: ResponseStationProtocol) {
        self.init(title: station.name.localized() ?? "",
                  subtitle: "\("Open hours:".localize()) \(station.availableTime ?? "")",
                  coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
                  image: station.annotationImage,
                  address: station.address.localized() ?? "",
                  isOpening: station.isOpening)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, coordinate, image, address, isOpening, checkinCounter, checkinDay, latitude, longitude
    }
    
    
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, image: UIImage, address: String, isOpening: Bool, checkinCounter: Int? = nil, checkinDay: String? = nil) {
        self.placemark    = MKPlacemark(coordinate: coordinate, addressDictionary: [title: ""])
        self.image        = image
        self.address      = address
        self.isOpening    = isOpening
        super.init()
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
        
    }
    
    required public convenience init?(coder aDecoder: NSCoder) {
        self.init(title: aDecoder.decodeObject(forKey: CodingKeys.title.rawValue) as? String ?? "",
                  subtitle: aDecoder.decodeObject(forKey: CodingKeys.subtitle.rawValue) as? String ?? "",
                  coordinate: CLLocationCoordinate2D(latitude: aDecoder.decodeDouble(forKey: CodingKeys.latitude.rawValue),
                                                     longitude: aDecoder.decodeDouble(forKey: CodingKeys.longitude.rawValue)),
                  image: aDecoder.decodeObject(forKey: CodingKeys.image.rawValue) as? UIImage ?? #imageLiteral(resourceName: "pinFull"),
                  address: aDecoder.decodeObject(forKey: CodingKeys.address.rawValue) as? String ?? "",
                  isOpening: aDecoder.decodeBool(forKey: CodingKeys.isOpening.rawValue),
                  checkinCounter: aDecoder.decodeInteger(forKey: CodingKeys.checkinCounter.rawValue),
                  checkinDay: aDecoder.decodeObject(forKey: CodingKeys.checkinDay.rawValue) as? String ?? "")
    }
    
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(image, forKey: CodingKeys.image.rawValue)
        aCoder.encode(address, forKey: CodingKeys.address.rawValue)
        aCoder.encode(isOpening, forKey: CodingKeys.isOpening.rawValue)
        aCoder.encode(checkinCounter, forKey: CodingKeys.checkinCounter.rawValue)
        aCoder.encode(checkinDay, forKey: CodingKeys.checkinDay.rawValue)
        aCoder.encode(title, forKey: CodingKeys.title.rawValue)
        aCoder.encode(subtitle, forKey: CodingKeys.subtitle.rawValue)
        aCoder.encode(coordinate.latitude, forKey: CodingKeys.latitude.rawValue)
        aCoder.encode(coordinate.longitude, forKey: CodingKeys.longitude.rawValue)
    }
    
}

extension Array where Element: BatteryStationPointAnnotation {
    func merge(new: Array<Element>) -> Array<Element> {
        return Array(Set<Element>(self).intersection(new).union(new))
    }
}
