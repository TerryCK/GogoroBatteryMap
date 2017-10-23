//
//  CollectionExtensions.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 19/09/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//


import MapKit
import Foundation
typealias StationDatas = (total: Int, available: Int, hasFlags: Int, hasCheckins: Int)

extension Collection where Iterator.Element: CustomPointAnnotation {
    //MARK: - Get the station informations count of total,available,hasFlags,hasCheckins
    var getStationData: StationDatas {
        return reduce((0,0,0,0))  { (result, element) -> StationDatas in
            return (result.total + 1,
                    result.available + (element.isOpening ? 1 : 0) ,
                    result.hasFlags + (element.checkinCounter > 0 ? 1 : 0),
                    result.hasCheckins + element.checkinCounter
            )
        }
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
