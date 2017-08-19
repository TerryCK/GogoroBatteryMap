//
//  CustomAnnotation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/10.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

final class CustomPointAnnotation: MKPointAnnotation {
    var image: UIImage!
    var placemark: MKPlacemark!
    var distance: String!
    
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, placemark: MKPlacemark, distance: String, image: UIImage ) {
    
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.placemark = placemark
        self.distance = distance
        self.image = image
    }
}
