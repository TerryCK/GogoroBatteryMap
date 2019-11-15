//
//  CountClusterAnnotationView.swift
//  SupplyMap
//
//  Created by CHEN GUAN-JHEN on 2019/7/18.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import Cluster

final class CountClusterAnnotationView: ClusterAnnotationView {
    
    override func configure() {
        super.configure()
        guard let annotation = annotation as? ClusterAnnotation else { return }
        let count = annotation.annotations.count
        let diameter = radius(for: count) * 4
        frame.size = CGSize(width: diameter, height: diameter)
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.5
        countLabel.backgroundColor = UIColor(red: 132/255, green: 183/255, blue: 82/256, alpha: 1)
    }
    
    
    func radius(for count: Int) -> CGFloat {
        return max(min(20, 2 * (CGFloat(exactly: count) ?? 0)),12)
    }
}
