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
            
            
            
            
            return CustomPointAnnotation(title: title,
                                         subtitle: "\(NSLocalizedString("Open hours:", comment: "")) \(station.availableTime ?? "")",
                                         coordinate: location,
                                         placemark: MKPlacemark(coordinate: location, addressDictionary: [title: ""]),
                                         image: getImage(with: station),
                                         address: address,
                                         isOpening: station.state == 1 ? true : false
            )
        }
    }
    
    typealias StationName = String
    
    
    
    
    func getImage(with name: StationName?) -> UIImage {
        
        let convenientKeywords = ["HiLife", "全聯", "7-ELEVEN", "全家"]
        let mallKeywords = ["家樂福", "大潤發", "Mall"]
        let gasStationKeyword = ["加油"]
        let goStationKeyword = ["Gogoro"]
        
        let closure = { (result: Bool, keyword: String) -> Bool in
            return result || name?.contains(keyword) ?? false
        }
        
        let isConvenientStore = convenientKeywords.reduce(false, closure)
        let isMall = mallKeywords.reduce(false, closure)
        let isGasStation = gasStationKeyword.reduce(false, closure)
        let isGoStation = goStationKeyword.reduce(false, closure)
        return isConvenientStore ? #imageLiteral(resourceName: "convenientStore") : isMall ? #imageLiteral(resourceName: "mallStore") : isGasStation ? #imageLiteral(resourceName: "gasStation") : isGoStation ? #imageLiteral(resourceName: "goStore") : #imageLiteral(resourceName: "pinFull")
    }
    
    private func getImage(with annotation: CustomPointAnnotation) -> UIImage {
        return annotation.isOpening ? #imageLiteral(resourceName: "building") : getImage(with: annotation.title)
    }
    
    private func getImage(with station: Station) -> UIImage {
        return station.state != 1 ? #imageLiteral(resourceName: "building") : getImage(with: station.locName?.twName)
    }
    
    func updataAnnotationImage(annotations: [CustomPointAnnotation]) {
        annotations.forEach { (element) in
            element.image = getImage(with: element)
        }
    }
}




