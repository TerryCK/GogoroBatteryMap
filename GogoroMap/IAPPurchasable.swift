//
//  IAPurchasable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/16.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//


import SwiftyStoreKit
import StoreKit
import Foundation
import UIKit
import Crashlytics


protocol IAPPurchasable: IAPAlartable {
    
    func getSKProduct(_ purchase: Product, completeHandler: @escaping (Result<[SKProduct]>) -> Void)
    func purchase(_ result: SKProduct)
    func restore()
    func verifyPurchase(_ purchase: Product)
    func handlePurchaseNotification(_ notification: Notification)
    func setupObserver()
}



extension IAPPurchasable where Self: UIViewController {
    
    func getSKProduct(_ product: Product, completeHandler: @escaping (Result<[SKProduct]>) -> Void) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([product.productId]) { result in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            if let product = result.retrievedProducts.first {
                completeHandler(.success([product]))
            } else {
                 self.showAlert(self.alertForProductRetrievalInfo(result))
                completeHandler(.fail(nil))
            }
        }
    }
    
    
    func purchase(_ result: SKProduct) {
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Remove Ad"])
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(result, quantity: 1, atomically: true) { result in
            if case .success(let purchase) = result,
                let product = Product.allCases.first(where: { $0.productId == purchase.productId }) {
                NetworkActivityIndicatorManager.shared.networkOperationFinished()
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                Answers.logPurchase(withPrice: purchase.product.price, currency: "TWD", success: true, itemName: purchase.productId, itemType: nil, itemId: nil, customAttributes: nil)
                self.verifyPurchase(product)
            }
            self.showAlert(self.alertForPurchase(result))
        }
    }
    
    
    
    func restore() {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            if let productId = results.restoredPurchases.first?.productId,
                let product = Product.allCases.first(where: { $0.productId == productId }) {
                Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Restore succeeded"])
                self.verifyPurchase(product)
            }
        }
    }
    
    
    private func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Keys.standard.secretKet)
        SwiftyStoreKit.verifyReceipt(using: appleValidator,  completion: completion)
    }
    
    func verifyPurchase(_ purchase: Product) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "VerifyPurchase"])
        verifyReceipt { result in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            guard case .success(let receipt) = result,
                case .purchased(let item) = SwiftyStoreKit.verifyPurchase(productId: purchase.productId, inReceipt: receipt) else {
                    print("\(#function) error can't verify puchase product" )
                    UserDefaults.standard.set(false, forKey: Keys.standard.hasPurchesdKey)
                    return
            }
             Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "VerifyPurchase purchased"])
             self.deliverPurchaseNotificationFor(identifier: item.productId)
            
        }
    }
    
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Deliver purchase"])
        UserDefaults.standard.set(true, forKey: Keys.standard.hasPurchesdKey)
        NotificationCenter.default.post(name: .init(rawValue: Keys.standard.removeAdsObserverName), object: identifier)
    }
    
    func setupPurchase() {
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            verifyPurchase(.removeAds)
        }
    }
}




