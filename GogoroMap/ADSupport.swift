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

protocol ADSupportable: GADBannerViewDelegate, NativeAdIdentify {
    
    func setupAd(with view: UIView)
    var bannerView: GADBannerView { set get }
    var adUnitID: String { get }
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
}

protocol NativeAdIdentify {
    var nativeAdID: String { get }
}

extension ADSupportable where Self: UIViewController {
    
    var adUnitID: String {
        switch Environment.environment {
        case .debug  : return "ca-app-pub-3940256099942544/2934735716"
        case .release: return Keys.standard.adUnitID
        }
    }
    
    var nativeAdID: String {
        switch Environment.environment {
        case .debug  : return "ca-app-pub-3940256099942544/3986624511"
        case .release: return Keys.standard.nativeAdID
        }
    }
    
    func setupAd(with view: UIView) {
        bannerView.isHidden = UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey)
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else { return }
        Answers.log(view: "Ad View")
        view.addSubview(bannerView)
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11.0, *) { bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor }
        bannerView.anchor(left: view.leftAnchor, bottom: bottomAnchor, right: view.rightAnchor)
        bannerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.adUnitID = adUnitID//"ca-app-pub-3940256099942544/2435281174"
        bannerView.load(DFPRequest())
    }
    
    func bridgeAd(_ bannerView: GADBannerView) {
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else { return }
        self.bannerView = bannerView
        bannerView.alpha = 0
        UIView.animate(withDuration: 1,
                       animations: { bannerView.alpha = 1 }
        )
    }
    
    func removeAds(view: UIView) {
        for subview in view.subviews {
            if subview is GADBannerView {
                subview.removeFromSuperview()
            } else {
                removeAds(view: subview)
            }
        }
    }
    
    func reloadBannerAds() {
        bannerView.load(DFPRequest())
    }
}

extension GADAdLoader {
    static func createNativeAd<T: GADAdLoaderDelegate & UIViewController & NativeAdIdentify>(delegate vc: T) -> GADAdLoader? {
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else {
            return nil
        }
        let adLoader = GADAdLoader(adUnitID: vc.nativeAdID,
                                   rootViewController: vc,
                                   adTypes: [ .unifiedNative ],
                                   options: nil)
        adLoader.delegate = vc
        adLoader.load(DFPRequest())
        return adLoader
    }
}
