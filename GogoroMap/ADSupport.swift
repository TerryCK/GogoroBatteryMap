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
    
    func setupAd(with view: UIView)
    var bannerView: GADBannerView { set get }
    var adUnitID: String { get }
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
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
//        guard Environment.environment == .release else { return }
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
        bannerView.adUnitID = adUnitID
        loadBannerAd()
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
    

      func loadBannerAd() {
        // Step 2 - Determine the view width to use for the ad width.
        let frame = { () -> CGRect in
          // Here safe area is taken into account, hence the view frame is used
          // after the view has been laid out.
          if #available(iOS 11.0, *) {
            return view.frame.inset(by: view.safeAreaInsets)
          } else {
            return view.frame
          }
        }()
        let viewWidth = frame.size.width

        // Step 3 - Get Adaptive GADAdSize and set the ad view.
        // Here the current interface orientation is used. If the ad is being preloaded
        // for a future orientation change or different orientation, the function for the
        // relevant orientation should be used.
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, Keys.standard.gadiPhone] as? [String]
        // Step 4 - Create an ad request and load the adaptive banner ad.
        bannerView.load(request)
      }
}

extension GADAdLoader {
    static func createNativeAd<T: GADAdLoaderDelegate & UIViewController & ADSupportable>(delegate vc: T) -> GADAdLoader? {
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else {
            return nil
        }
        let adLoader = GADAdLoader(adUnitID: vc.adUnitID,
                                   rootViewController: vc,
                                   adTypes: [ .unifiedNative ],
                                   options: nil)
        adLoader.delegate = vc
        adLoader.load(GADRequest())
        return adLoader
    }
    
    func update() {
        load(GADRequest())
    }
}
