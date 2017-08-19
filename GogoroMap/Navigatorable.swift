//
//  Navigatorable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit

protocol Navigatorable {
    func go(to destination: CustomPointAnnotation)
}

extension Navigatorable {
    
    func go(to destination: CustomPointAnnotation) {
        let mapItem = MKMapItem(placemark: destination.placemark)
        mapItem.name = " \(destination.title!)(Gogoro \(NSLocalizedString("Battery Station", comment: "")))"
        print("mapItem.name \(String(describing: mapItem.name))")
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

