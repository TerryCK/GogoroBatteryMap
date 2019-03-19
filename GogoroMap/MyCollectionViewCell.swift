//
//  TableViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit

final class MyCollectionViewCell: BaseCollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = "Total:".localize()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = "距離: 10 km"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = " "
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let myImage = UIImageView(image: #imageLiteral(resourceName: "pinFull"))
        myImage.contentMode = .scaleAspectFit
        return myImage
    }()
    
    private lazy var subStackView: UIStackView = {
        let views: [UIView] = [distanceLabel , dateLabel]
        let myStackView = UIStackView(arrangedSubviews: views)
        myStackView.alignment = .bottom
        myStackView.distribution = .fillEqually
        myStackView.axis = .horizontal
        return myStackView
    }()
    
    override func setupViews() {
        super.setupViews()
        viewContainer.addSubview(titleLabel)
        titleLabel.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: nil, topPadding: 6, leftPadding: 20)
        viewContainer.addSubview(imageView)
        imageView.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, topPadding: 2 , leftPadding: 18, bottomPadding: 0, rightPadding: 0, width: 30, height: 30)
        viewContainer.addSubview(subStackView)
        subStackView.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: viewContainer.bottomAnchor, right: viewContainer.rightAnchor, topPadding: 5, leftPadding: 12, bottomPadding: 12, rightPadding: 6, width: 0, height: 20)
        
        backgroundColor = .clear
        alpha = 0.98
    }
    
    func configure(index: Int, station: BatteryStationPointAnnotation, userLocation: CLLocation) -> Self {
        titleLabel.text = "\(index + 1 ). \(station.title ?? "")"
        dateLabel.text = station.checkinCounter ?? 0 > 0 ? "打卡日期: \(station.checkinDay ?? "")" : ""
        imageView.image = station.iconImage
        distanceLabel.text = "距離: \(String(format:"%.1f", station.distance(from: userLocation) / 1000)) km"
        return self
    }
    
    
}




