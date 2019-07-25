//
//  ADSupport.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/4/8.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation
import GoogleMobileAds
import Crashlytics

protocol ADSupportable: GADBannerViewDelegate {
    func setupAd()
    var bannerView: GADBannerView { set get }
    var adUnitID: String { get }
    func didReceiveAd(_ bannerView: GADBannerView)
    
}

extension ADSupportable where Self: UIViewController {
    
    func setupAd() {
        bannerView.isHidden = UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey)
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else { return }
        Answers.log(view: "Ad View")
        view.addSubview(bannerView)
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11.0, *) { bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor }
        bannerView.anchor(top: nil, left: view.leftAnchor, bottom: bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
        
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.adUnitID = adUnitID
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, Keys.standard.gadiPhone]
        bannerView.load(request)
    }
    
    func didReceiveAd(_ bannerView: GADBannerView){
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else { return }
        self.bannerView = bannerView
        bannerView.alpha = 0
        UIView.animate(withDuration: 1,
                       animations: { bannerView.alpha = 1 }
        )
    }
    
}
