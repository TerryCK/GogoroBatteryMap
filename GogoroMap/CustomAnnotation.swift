//
//  CustomAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/10.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//
import UIKit
import MapKit
import Foundation

final class CustomPointAnnotation: MKPointAnnotation, NSCoding, Decodable {
    var image: UIImage!
    var placemark: MKPlacemark!
    var checkinCounter: Int = 0
    var address: String = ""
    var isOpening: Bool = false
    var checkinDay: String = ""
    
    
    init(title: String,
         subtitle: String,
         coordinate: CLLocationCoordinate2D,
         placemark: MKPlacemark,
         image: UIImage,
         address: String,
         isOpening: Bool,
         checkinCounter: Int = 0,
         checkinDay: String = " ") {
        
        super.init()
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.placemark = placemark
        self.image = image
        self.address = address
        self.isOpening = isOpening
        self.checkinDay = checkinDay
        self.checkinCounter = checkinCounter
        
    }
    
    enum CodingKeys: String, CodingKey {
        case imageKey, placemarkKey, checkinCounterKey, addressKey, isOpeningKey, checkinDayKey, titleKey, subtitleKey, latitudeKey, longtitudeKey
    }
    private static let imageKey = "imageKey"
    private static let placemarkKey = "placemarkKey"
    private static let checkinCounterKey = "checkinCounterKey"
    private static let addressKey = "addressKey"
    private static let isOpeningKey = "isOpeningKey"
    private static let checkinDayKey = "checkinDayKey"
    private static let titleKey = "titleKey"
    private static let subtitleKey = "subtitleKey"
    private static let latitudeKey = "latitudeKey"
    private static let longtitudeKey = "longitudeKey"
    
    
    // MARK:- Bridge
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isOpening = try container.decode(Bool.self, forKey: .isOpeningKey)
        let image =  #imageLiteral(resourceName: "pinFull")

        let title = try container.decode(String.self, forKey: .titleKey)
        let subtitle = try container.decode(String.self, forKey: .subtitleKey)
        let latitude = try container.decode(String.self, forKey: .latitudeKey)
        let longitude = try container.decode(String.self, forKey: .longtitudeKey)
        
        let address = try container.decode(String.self, forKey: .addressKey)
        
        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
        
        let placemark = MKPlacemark()
        
        let checkinDay = try container.decode(String.self, forKey: .checkinDayKey)
        let checkinCounterStr = try container.decode(String.self, forKey: .checkinCounterKey)
        let checkinCounter = Int(checkinCounterStr) ?? 0
        
        self.init(title: title,
                  subtitle: subtitle,
                  coordinate: coordinate,
                  placemark: placemark,
                  image: image,
                  address: address,
                  isOpening: isOpening,
                  checkinCounter: checkinCounter,
                  checkinDay: checkinDay)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        
        let isOpening = aDecoder.decodeBool(forKey: CustomPointAnnotation.isOpeningKey)
        let image = aDecoder.decodeObject(forKey: CustomPointAnnotation.imageKey) as? UIImage ?? #imageLiteral(resourceName: "pinFull")
        let title = aDecoder.decodeObject(forKey: CustomPointAnnotation.titleKey) as? String ?? ""
        let subtitle = aDecoder.decodeObject(forKey: CustomPointAnnotation.subtitleKey) as? String ?? ""
        let latitude = aDecoder.decodeObject(forKey: CustomPointAnnotation.latitudeKey) as? String ?? ""
        let longitude = aDecoder.decodeObject(forKey: CustomPointAnnotation.longtitudeKey) as? String ?? ""
        let address = aDecoder.decodeObject(forKey: CustomPointAnnotation.addressKey) as? String ?? ""
        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
        let placemark = aDecoder.decodeObject(forKey: CustomPointAnnotation.placemarkKey) as? MKPlacemark ?? MKPlacemark()
        let checkinDay = aDecoder.decodeObject(forKey: CustomPointAnnotation.checkinDayKey) as? String ?? ""
        let checkinCounterStr = aDecoder.decodeObject(forKey: CustomPointAnnotation.checkinCounterKey) as? String ?? ""
        let checkinCounter = Int(checkinCounterStr) ?? 0
        
        
        self.init(title: title,
                  subtitle: subtitle,
                  coordinate: coordinate,
                  placemark: placemark,
                  image: image,
                  address: address,
                  isOpening: isOpening,
                  checkinCounter: checkinCounter,
                  checkinDay: checkinDay)
    }
    
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(image, forKey: CustomPointAnnotation.imageKey)
        aCoder.encode(placemark, forKey: CustomPointAnnotation.placemarkKey)
        aCoder.encode(address, forKey: CustomPointAnnotation.addressKey)
        aCoder.encode(isOpening, forKey: CustomPointAnnotation.isOpeningKey)
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        let checkinCounterStr = String(checkinCounter)
        
        aCoder.encode(latitude, forKey: CustomPointAnnotation.latitudeKey)
        aCoder.encode(longitude, forKey: CustomPointAnnotation.longtitudeKey)
        aCoder.encode(checkinCounterStr, forKey: CustomPointAnnotation.checkinCounterKey)
        aCoder.encode(checkinDay, forKey: CustomPointAnnotation.checkinDayKey)
        
        guard
            let title = title,
            let subtitle = subtitle else { return }
        aCoder.encode(title, forKey: CustomPointAnnotation.titleKey)
        aCoder.encode(subtitle, forKey: CustomPointAnnotation.subtitleKey)
    }
    
    var toCLLocation: CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
}
