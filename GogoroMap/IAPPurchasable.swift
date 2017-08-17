//
//  IAPurchasable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/16.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//


// do verify recipts

import SwiftyStoreKit
import StoreKit
import Foundation
import UIKit


protocol IAPPurchasable: IAPAlartable {
    
    func getInfo(_ purchase: RegisteredPurchase, completeHandle: @escaping ProductsRequestCompletionHandler)
    func purchase(_ result: SKProduct)
    func restore()
    
}



extension IAPPurchasable where Self: UIViewController {
     
    func getInfo(_ purchase: RegisteredPurchase, completeHandle: @escaping ProductsRequestCompletionHandler) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([Bundle.id + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if let product = result.retrievedProducts.first {
                //            let priceString = product.localizedPrice ?? ""
                completeHandle(true, [product])
                //            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
                return
            }
            self.showAlert(self.alertForProductRetrievalInfo(result))
            completeHandle(false, nil)
        }
    }
    
    
    func purchase(_ result: SKProduct) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(result, quantity: 1, atomically: true) { result in
            if case .success(let purchase) = result {
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.deliverPurchaseNotificationFor(identifier: purchase.productId)
            }
            self.showAlert(self.alertForPurchase(result))
        }
    }
    
    
    
    func restore() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            
            for purchase in results.restoredPurchases where purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
            
            let productId = results.restoredPurchases.first?.productId
            self.deliverPurchaseNotificationFor(identifier: productId)
            self.showAlert(self.alertForRestore(results))
        }
    }

    
    
    
    
    
    func verifyReceipt() {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.showAlert(self.alertForVerifyReceipt(result))
        }
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production)
        let password = Keys.standard.secretKet
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: password, completion: completion)
    }
    
    
    
    
    func verifyPurchase(_ purchase: RegisteredPurchase) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                
                let productId = Bundle.id + "." + purchase.rawValue
                
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt
                )
                //                    self.showAlert(self.alertForVerifyPurchase(purchaseResult))
                self.verifyPurchaseResultParser(with: purchaseResult, purchase: purchase)
                
            case .error:
                self.showAlert(self.alertForVerifyReceipt(result))
            }
        }
    }
    
    private func verifyPurchaseResultParser(with result: VerifyPurchaseResult, purchase: RegisteredPurchase) {
        
        switch result {
        case .purchased:
            print("Product is purchased")
            NotificationCenter.default.post(name: RegisteredPurchase.observerName, object: purchase.rawValue)
            
        case .notPurchased:
            print("This product has never been purchased")
            
            //           self.showAlert(alertWithTitle("Not purchased", message: "This product has never been purchased"))
        }
        
    }
    
    
    
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        NetworkActivityIndicatorManager.networkOperationFinished()
        //        purchasedProductIdentifiers.insert(identifier)
        //        UserDefaults.standard.set(true, forKey: identifier)
        //        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: RegisteredPurchase.observerName, object: identifier)
    }
    
}


