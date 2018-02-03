//
//  BaseCollectionViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//
import UIKit


class BaseCollectionViewCell: UICollectionViewCell {
    lazy var viewContainer: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        view.backgroundColor = .white
       return view
    }()
 
    
    lazy var viewContainer2: UIView = {
        let containerView = UIView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 1
        

        self.addSubview(blurEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        vibrancyEffectView.frame = self.bounds
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        let vibrancyEffectContentView = vibrancyEffectView.contentView
        vibrancyEffectContentView.addSubview(containerView)
        
        var buttomAnchor = vibrancyEffectContentView.bottomAnchor
        
        if #available(iOS 11.0, *), UIDevice.isiPhoneX {
            buttomAnchor = vibrancyEffectContentView.safeAreaLayoutGuide.bottomAnchor
        }
        
        containerView.anchor(top: vibrancyEffectContentView.topAnchor,
                             left: vibrancyEffectContentView.leftAnchor,
                             bottom: buttomAnchor,
                             right:  vibrancyEffectContentView.rightAnchor)
        
        
        return containerView
       
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
