//
//  IAPProducts.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/16.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import StoreKit

enum RegisteredPurchase: String {
    case removeAds = "RemoveAds"
    static let removedProductID = (Bundle.main.bundleIdentifier ?? "") + "." + RegisteredPurchase.removeAds.rawValue
}

