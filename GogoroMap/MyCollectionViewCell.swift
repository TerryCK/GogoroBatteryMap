//
//  TableViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import Foundation
import UIKit


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
        
    }
    
//    override lazy var viewContainer: UIView = {
//        let containerView = UIView()
//        let blurEffect = UIBlurEffect(style: .extraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = self.bounds
//        blurEffectView.alpha = 0.87
//
//        self.addSubview(blurEffectView)
//
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//
//        vibrancyEffectView.frame = self.bounds
//        blurEffectView.contentView.addSubview(vibrancyEffectView)
//
//        let vibrancyEffectContentView = vibrancyEffectView.contentView
//        vibrancyEffectContentView.addSubview(containerView)
//
//        var buttomAnchor = vibrancyEffectContentView.bottomAnchor
//        if #available(iOS 11.0, *), UIDevice.isiPhoneX {
//            let safeAreaBottom: NSLayoutYAxisAnchor = vibrancyEffectContentView.safeAreaLayoutGuide.bottomAnchor
//            buttomAnchor = safeAreaBottom
//        }
//
//        containerView.anchor(top: vibrancyEffectContentView.topAnchor, left: vibrancyEffectContentView.leftAnchor, bottom: buttomAnchor, right:  vibrancyEffectContentView.rightAnchor)
//
//        return containerView
//    }()
}




