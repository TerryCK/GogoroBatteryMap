//
//  NativeAdTableViewCell.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/11/29.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class NativeAdTableViewCell: UITableViewCell {
    
    static func builder() -> NativeAdTableViewCell {
        Bundle.main.loadNibNamed("NativeAdTableViewCell", owner: nil, options: nil)?.first as! NativeAdTableViewCell
    }
    
    @IBOutlet weak var nativeAdView: GADUnifiedNativeAdView! {
        didSet {
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            nativeAdView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.layer.cornerRadius = 5
            iconImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var callToActionButton: UIButton! {
        didSet {
            callToActionButton.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var advertiserRatingLabel: UILabel!
    @IBOutlet weak var mediaView: GADMediaView! {
        didSet {
            mediaView.contentMode = .scaleAspectFill
            mediaView.layer.cornerRadius = 10
            mediaView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var priceStoreLabel: UILabel!
    @IBOutlet weak var adLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    func combind(nativeAd: GADUnifiedNativeAd) {
        nativeAdView.nativeAd = nativeAd
        iconImageView.image = nativeAd.icon?.image
        advertiserRatingLabel.text = (nativeAd.advertiser ?? "") + String(repeating: "🌟", count: nativeAd.starRating?.intValue ?? 0)
        let price = nativeAd.price ?? ""
        let store = nativeAd.store ?? ""
        bodyLabel.text = nativeAd.body
        priceStoreLabel.text = price + store + "   "
        mediaView.mediaContent = nativeAd.mediaContent
        callToActionButton.setTitle(nativeAd.callToAction ?? "", for: .normal)
    }
    
    func combind(index: Int, nativeAd: GADUnifiedNativeAd) {
        let sponsored = "(\("sponsored".localize()))"
        headlineLabel.text = nativeAd.headline.map { "\(index). " + $0 + sponsored }
        combind(nativeAd: nativeAd)
    } 
}
