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
    let borderColor: UIColor
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, style: ClusterAnnotationStyle, borderColor: UIColor) {
        self.borderColor = borderColor
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, style: style)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(with type: ClusterAnnotationStyle) {
        super.configure(with: type)
        
        switch type {
        case .image:
            layer.borderWidth = 0
        case .color:
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 2
        }
    }
}
