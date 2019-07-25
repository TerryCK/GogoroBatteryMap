//
//  IAPProducts.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/16.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import StoreKit

enum Product: String, CaseIterable {
    case removeAds = "RemoveAds"
//    static let removedProductID = (Bundle.main.bundleIdentifier ?? "") + "." + Product.removeAds.rawValue
    
    
    var productId: String {
        guard let bundleId = Bundle.main.bundleIdentifier else { return "" }
        return "\(bundleId).\(rawValue)"
    }
}

