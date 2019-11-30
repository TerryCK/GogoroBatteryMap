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

    @IBOutlet weak var nativeAdView: GADUnifiedNativeAdView! {
        didSet {
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            nativeAdView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.layer.cornerRadius = iconImageView.frame.width/2
            iconImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var advertiserLabel: UILabel!
    @IBOutlet weak var mediaView: GADMediaView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var adLabel: UILabel!
    
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var storeLabel: UILabel!
    
    func setup(nativeAd: GADUnifiedNativeAd?) {
        nativeAdView.nativeAd = nativeAd
        iconImageView.image = nativeAd?.icon?.image
        advertiserLabel.text = nativeAd?.advertiser
        headlineLabel.text = nativeAd?.headline
        priceLabel.text = nativeAd?.price
        ratingImageView.image = imageOfStars(from: nativeAd?.starRating)
        storeLabel.text = nativeAd?.store
        mediaView.mediaContent = nativeAd?.mediaContent
        
        nativeAd?.register(self, clickableAssetViews: [GADUnifiedNativeAssetIdentifier.mediaViewAsset: self], nonclickableAssetViews: [:])
//        nativeAd?.register(self,
//                           clickableAssetViews: [GADUnifiedNativeAssetIdentifier.callToActionAsset : nativeAdView.callToActionView!],
//                           nonclickableAssetViews: [:])
    }
    
    func combind(index: Int) -> Self {
        let headLine = UIApplication.mapViewController?.nativeAd?.headline
        headlineLabel.text = headLine.map { "\(index). " + $0 }
        return self
    }
    
    override func awakeFromNib() {
         setup(nativeAd: UIApplication.mapViewController?.nativeAd)
    }
    
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else { return nil }
        switch rating {
        case 5...:    return UIImage(named: "stars_5")
        case 4.5..<5: return UIImage(named: "stars_4_5")
        case 4..<4.5: return UIImage(named: "stars_4")
        case 3.5..<4: return UIImage(named: "stars_3_5")
        default: return nil
        }
    }
}
