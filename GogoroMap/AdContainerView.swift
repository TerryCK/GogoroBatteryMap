//
//  ContainerView.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/10.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class AdContainerView: UIView {
    
    static let shared = AdContainerView()
    
    lazy var nativeAdView: GADBannerView = {
        let gAdView = GADBannerView()
        let request: GADRequest = GADRequest()
        gAdView.adUnitID = Keys.standard.adUnitID
        request.testDevices = [kGADSimulatorID, Keys.standard.gadiPhone]
        gAdView.adSize = kGADAdSizeSmartBannerPortrait
        gAdView.load(request)
        return gAdView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(nativeAdView)
        nativeAdView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
