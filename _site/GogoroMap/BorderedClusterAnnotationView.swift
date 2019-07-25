//
//  BorderedClusterAnnotationView.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 08/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import MapKit
import UIKit
import Cluster

final class BorderedClusterAnnotationView: ClusterAnnotationView {
    
    override func configure(with style: ClusterAnnotationStyle) {
        super.configure(with: style)
        switch style {
        case .image:
            layer.borderWidth = 5
        case let .color(color, radius):
            layer.borderColor = color.cgColor
            layer.borderWidth = radius
        }
    }
}
