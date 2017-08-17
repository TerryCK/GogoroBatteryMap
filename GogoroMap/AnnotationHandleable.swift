//
//  AnnotationHandleable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//


import MapKit
import Foundation
import CoreLocation

protocol AnnotationHandleable {
    func getObjectArray(from stations: [Station], userLocation: CLLocation) -> [CustomPointAnnotation]
}

extension AnnotationHandleable {
    
    func getObjectArray(from stations: [Station], userLocation: CLLocation) -> [CustomPointAnnotation] {
        return stations.map { (station) -> CustomPointAnnotation in
            
            let latitude: CLLocationDegrees = station.latitude ?? 0.0
            let longitude: CLLocationDegrees = station.longitude ?? 0.0
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let title = station.locName?.twName ?? ""
            let image = station.state != 1 ? #imageLiteral(resourceName: "building") : station.availableTime?.contains("24") ?? false ? #imageLiteral(resourceName: "pinFull") : #imageLiteral(resourceName: "shoTiime")
            
            return CustomPointAnnotation(title: title,
                                         subtitle: "營業時間: " + station.availableTime! ,
                                         coordinate: location,
                                         placemark: MKPlacemark(coordinate: location, addressDictionary: [title: ""]),
                                         distance: CLLocation(latitude: latitude, longitude: longitude).distance(from: userLocation).km,
                                         image: image
            )
        }
    }
}
