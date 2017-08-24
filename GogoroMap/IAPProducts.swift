//
//  IAPProducts.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/16.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation
import StoreKit

public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()


enum RegisteredPurchase: String {
    //    case purchase1
    //    case purchase2
    //    case nonConsumablePurchase
    //    case consumablePurchase
    //    case autoRenewablePurchase
    //    case nonRenewingPurchase
    
    case removeAds = "RemoveAds"
    static let removedProductID = Bundle.id + "." + RegisteredPurchase.removeAds.rawValue
    static let observerName = NSNotification.Name(rawValue: RegisteredPurchase.removeAds.rawValue)
}






// discard

//public struct Products {
//    public static let observerName = NSNotification.Name(rawValue: RegisteredPurchase.removeAds.rawValue)
////    public static let secretKey = Keys.standard.secretKet
////    public static let removeAds = RegisteredPurchase.removeAds.rawValue
//
//}


//public struct Products {
//
//    private enum RegisteredPurchase: String {
//        case removeAds = "RemoveAds"
//    }
//    public static let observerName = NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification)
//    private static let bundleID = "com.MapVision.GogoroMap"
//    public static let removeAds = "\(bundleID).\(RegisteredPurchase.removeAds.rawValue)"
//
//    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [Products.removeAds]
//
//    public static let store = IAPHelper(productIds: Products.productIdentifiers)
//
//}
