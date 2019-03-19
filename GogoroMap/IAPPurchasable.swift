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


protocol PurchaseItem { }
extension String: PurchaseItem { }
extension RegisteredPurchase: PurchaseItem { }
typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

protocol IAPPurchasable: IAPAlartable {
    
    func getInfo(_ purchase: RegisteredPurchase, completeHandle: @escaping ProductsRequestCompletionHandler)
    func purchase(_ result: SKProduct)
    func restore()
    
    func verifyPurchase<T: PurchaseItem>(_ purchase: T)
    func handlePurchaseNotification(_ notification: Notification)
    
    
    func setupObserver()
}



extension IAPPurchasable where Self: UIViewController {
    
    func getInfo(_ purchase: RegisteredPurchase, completeHandle: @escaping ProductsRequestCompletionHandler) {
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Get purchase item list"])
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        
        let proudctInfo = "\(Bundle.id).\(purchase.rawValue)"
        
        SwiftyStoreKit.retrieveProductsInfo([proudctInfo]) { result in
            NetworkActivityIndicatorManager.shared.networkOperationFinished() 
            if let product = result.retrievedProducts.first {
                completeHandle(true, [product])
                return
            }
            self.showAlert(self.alertForProductRetrievalInfo(result))
            completeHandle(false, nil)
        }
    }
    
    
    func purchase(_ result: SKProduct) {
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Remove Ad"])
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(result, quantity: 1, atomically: true) { result in
            if case .success(let purchase) = result {
                NetworkActivityIndicatorManager.shared.networkOperationFinished()
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                Answers.logPurchase(withPrice: purchase.product.price, currency: "TWD", success: true, itemName: purchase.productId, itemType: nil, itemId: nil, customAttributes: nil)
                Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents,
                                       customAttributes: [Log.sharedName.purchaseEvent: "Purchase succeeded"])
                self.verifyPurchase(purchase.productId)
            }
            self.showAlert(self.alertForPurchase(result))
        }
    }
    
    
    
    func restore() {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            
            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            
            if let productId = results.restoredPurchases.first?.productId {
                Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Restore succeeded"])
                self.verifyPurchase(productId)
            }
        }
    }
    
    
    private func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Keys.standard.secretKet)

        SwiftyStoreKit.verifyReceipt(using: appleValidator,  completion: completion)
    }
    
    
    //    func verifyReceipt() {
    //
    //        NetworkActivityIndicatorManager.shared.networkOperationStarted()
    //        verifyReceipt { result in
    //            NetworkActivityIndicatorManager.shared.networkOperationFinished()
    //            self.showAlert(self.alertForVerifyReceipt(result))
    //        }
    //    }
    
    
    
    func verifyPurchase<T: PurchaseItem>(_ purchase: T) {
        
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        print("verify Purchase")
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "VerifyPurchase"])
        verifyReceipt { result in
            
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "VerifyReceipt succeeded"])
                var productId: String
                if let purchase = purchase as? RegisteredPurchase {
                    productId = Bundle.id + "." + purchase.rawValue
                } else {
                    productId = purchase as? String ?? ""
                }
                
                let purchaseResult = SwiftyStoreKit.verifyPurchase (
                    productId: productId,
                    inReceipt: receipt
                )
                
                switch purchaseResult {
                case .purchased(let item):
                    Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "VerifyPurchase purchased"])
                    
                    self.deliverPurchaseNotificationFor(identifier: item.productId)
                    
                default:
                    print("no purchased item with:", productId)
                }
                
            case .error:
                UserDefaults.standard.set(false, forKey: Keys.standard.hasPurchesdKey)
                break
            }
        }
    }
    
    
    fileprivate func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else {
            return }
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Deliver purchase"])
        
        NetworkActivityIndicatorManager.shared.networkOperationFinished()
        UserDefaults.standard.set(true, forKey: Keys.standard.hasPurchesdKey)
        NotificationCenter.default.post(name: .removeAds, object: identifier)
    }
    
    func setupPurchase() {
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            verifyPurchase(RegisteredPurchase.removeAds)
        }
    }
}




