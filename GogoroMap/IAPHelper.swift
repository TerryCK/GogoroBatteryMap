////  Discard 2017/8/17.
////  InAppPurchases.swift
////  GogoroMap
////
////  Created by 陳 冠禎 on 2017/8/14.
////  Copyright © 2017年 陳 冠禎. All rights reserved.
////
//
//import Foundation
//import StoreKit
////import SwiftyStoreKit
//
//func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
//    return productIdentifier.components(separatedBy: ".").last
//}
//
//
//public typealias ProductIdentifier = String
////public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()
//
//
//open class IAPHelper : NSObject  {
//    
//    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
//    fileprivate let productIdentifiers: Set<ProductIdentifier>
//    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
//    fileprivate var productsRequest: SKProductsRequest?
//    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
//    
//    
//    public init(productIds: Set<ProductIdentifier>) {
//        productIdentifiers = productIds
//        for productIdentifier in productIds {
//            
//            
//            // MARK: Jailbreak can modify this setup, no reliable way! with UserDefaults, resolve it by Validating App Stroe Receipts
//            
//            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
//            if purchased {
//                purchasedProductIdentifiers.insert(productIdentifier)
//                print("Previously purchased: \(productIdentifier)")
//            } else {
//                print("Not purchased: \(productIdentifier)")
//            }
//        }
//        super.init()
//        SKPaymentQueue.default().add(self)
//    }
//    
//}
//
//// MARK: - StoreKit API
//
//extension IAPHelper {
//    
//    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
//        productsRequest?.cancel()
//        productsRequestCompletionHandler = completionHandler
//        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
//        productsRequest!.delegate = self
//        productsRequest!.start()
//    }
//    
//    public func buyProduct(_ product: SKProduct) {
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        
//        print("Buying \(product.productIdentifier)...")
//        let payment = SKPayment(product: product)
//        SKPaymentQueue.default().add(payment)
//    }
//    
//    public func restorePurchases() {
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }
//    
//    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
//        return purchasedProductIdentifiers.contains(productIdentifier)
//    }
//    
//    public class func canMakePayments() -> Bool {
//        return SKPaymentQueue.canMakePayments()
//    }
//    
//    
//}
//
//// MARK: - SKProductsRequestDelegate
//
//extension IAPHelper: SKProductsRequestDelegate {
//    
//    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        let products = response.products
//        print("Loaded list of products...")
//        productsRequestCompletionHandler?(true, products)
//        clearRequestAndHandler()
//        
//        for p in products {
//            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
//        }
//    }
//    
//    public func request(_ request: SKRequest, didFailWithError error: Error) {
//        print("Failed to load list of products.")
//        print("Error: \(error.localizedDescription)")
//        productsRequestCompletionHandler?(false, nil)
//        clearRequestAndHandler()
//    }
//    
//    private func clearRequestAndHandler() {
//        productsRequest = nil
//        productsRequestCompletionHandler = nil
//    }
//}
//
//// MARK: - SKPaymentTransactionObserver
//
//extension IAPHelper: SKPaymentTransactionObserver {
//    
//    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        
//        for transaction in transactions {
//            
//            switch (transaction.transactionState) {
//            case .purchased:
//                complete(transaction: transaction)
//                 
//            case .failed:
//                fail(transaction: transaction)
//                
//            case .restored:
//                restore(transaction: transaction)
//                
//            case .deferred:
//                break
//            case .purchasing:
//                break
//            }
//        }
//        
//    }
//    
//    private func complete(transaction: SKPaymentTransaction) {
//        print("complete...")
//        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
//        SKPaymentQueue.default().finishTransaction(transaction)
//    }
//    
//    private func restore(transaction: SKPaymentTransaction) {
//        
//        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
//        print("restore... \(productIdentifier)")
//        deliverPurchaseNotificationFor(identifier: productIdentifier)
//        SKPaymentQueue.default().finishTransaction(transaction)
//    }
//    
//    private func fail(transaction: SKPaymentTransaction) {
//        print("fail...")
//        NetworkActivityIndicatorManager.networkOperationFinished()
//        if let transactionError = transaction.error as? NSError {
//            if transactionError.code != SKError.paymentCancelled.rawValue {
//                print("Transaction Error: \(transaction.error?.localizedDescription)")
//            }
//        }
//        
//        SKPaymentQueue.default().finishTransaction(transaction)
//    }
//    
//    private func deliverPurchaseNotificationFor(identifier: String?) {
//        guard let identifier = identifier else { return }
//        NetworkActivityIndicatorManager.networkOperationFinished()
//        purchasedProductIdentifiers.insert(identifier)
//        UserDefaults.standard.set(true, forKey: identifier)
//        UserDefaults.standard.synchronize()
//        NotificationCenter.default.post(name: Products.observerName, object: identifier)
//    }
//    
//}
