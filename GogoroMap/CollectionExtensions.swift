//
//  CollectionExtensions.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 19/09/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//


import MapKit
import Foundation

extension Collection where Iterator.Element: CustomPointAnnotation {
    var getStationData: (totle: Int, available: Int, hasFlags: Int, hasCheckins: Int) {
        var total: Int = 0, available: Int = 0, hasFlags: Int = 0, hasCheckins: Int = 0
        self.forEach {
            available += $0.isOpening ? 1 : 0
            hasFlags += $0.checkinCounter > 0 ? 1 : 0
            hasCheckins += $0.checkinCounter
            total += 1
        }
        return (total, available, hasFlags, hasCheckins)
    }
}

extension Collection where Iterator.Element == Station {
    
    var customPointAnnotations: [CustomPointAnnotation] {
        return self.map { (station) -> CustomPointAnnotation in
            let isEnglish = NSLocale.preferredLanguages[0] == "en"
            let latitude: CLLocationDegrees = station.latitude ?? 0.0
            let longitude: CLLocationDegrees = station.longitude ?? 0.0
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let twName = station.locName?.twName ?? ""
            let engName = station.locName?.engName ?? ""
            
            let twAddress = station.address?.twName ?? ""
            let engAddress = station.address?.engName ?? ""
            
            let address = isEnglish ? engAddress : twAddress
            let title = isEnglish ? engName : twName
            let image = station.state != 1 ? #imageLiteral(resourceName: "building") : station.availableTime?.contains("24") ?? false ? #imageLiteral(resourceName: "pinFull") : #imageLiteral(resourceName: "shortTime")
            
            
            return CustomPointAnnotation(title: title,
                                         subtitle: "\(NSLocalizedString("Open hours:", comment: "")) \(station.availableTime ?? "")",
                coordinate: location,
                placemark: MKPlacemark(coordinate: location, addressDictionary: [title: ""]),
                image: image,
                address: address,
                isOpening: station.state == 1 ? true : false
            )
        }
    }
}
