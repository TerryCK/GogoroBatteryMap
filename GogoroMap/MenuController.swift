//
//  TestViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/11.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import StoreKit
import Crashlytics

protocol ManuDelegate: AnyObject {
    var  clusterSwitcher: ClusterStatus { set get }
    
}

protocol MenuDataSource: AnyObject {
    var batteryStationPointAnnotations: [BatteryStationPointAnnotation] { get }
}

extension MenuController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}

final class MenuController: UICollectionViewController, StationsViewCellDelegate {
    
    weak var delegate: ManuDelegate?
    weak var dataSource: MenuDataSource?
    
    var refreshButton: UIButton?
    
    var timer: Timer?
    
    var products = [SKProduct]() {
        didSet { collectionView?.reloadData()  }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviagtionAndCollectionView()
        setupPurchaseItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "Menu Page", contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .removeAds, object: nil)
    }
    
    // MARK: - CollectionView logics
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: type(of: self)), for: indexPath) as! StationsViewCell
        
        cell.delegate = self
        cell.analytics = StationAnalyticsModel(dataSource?.batteryStationPointAnnotations ?? [])
        
        if !products.isEmpty {
            cell.product = products.first
        }
        
        cell.purchaseHandler = purchase
        
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            cell.buyStoreButtonStackView.removeFromSuperview()
            cell.setupThanksLabel()
        }
        
        refreshButton = cell.dataUpdateButton
        return cell
    }
    
    
    
    // MARK: - Setup & initializing Views
    private func setupNaviagtionAndCollectionView() {
        
        navigationController?.view.layer.cornerRadius = 10
        navigationController?.view.layer.masksToBounds = true
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Information".localize()
        navigationItem.titleView?.layer.cornerRadius = 10
        navigationItem.titleView?.layer.masksToBounds = true
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsetsMake( 0, 0, 10, 0)
        collectionView?.isScrollEnabled = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.register(StationsViewCell.self, forCellWithReuseIdentifier: String(describing: type(of: self)))
    }
    
    // MARK: - Events
    private func open(url: String) {
        guard let checkURL = URL(string: url), UIApplication.shared.canOpenURL(checkURL) else { return }
        UIApplication.shared.openURL(checkURL)
    }
}

// MARK: - Perform target's events
extension MenuController {
    
    @objc func performGuidePage() {
        
        //       navigationController?.pushViewController(BackupViewController(), animated: true)
    }
    
    //    @objc func performGuidePage() {
    //        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Guide"])
    //        present(GuidePageViewController(), animated: true, completion: nil)
    //    }
    
    @objc func recommand() {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Recommand"])
        let head = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="
        let foot = "&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
        let url = head + Keys.standard.appID + foot
        open(url: url)
    }
    
    @objc func moreApp() {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "MoreApp"])
        open(url: "https://itunes.apple.com/tw/app/id1192891004?l=zh&mt=8")
    }
    
    @objc func shareThisApp() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Share"])
        guard let url = URL(string: "https://itunes.apple.com/tw/app/id\(Keys.standard.appID)?l=zh&mt=8") else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    @objc func clusterSwitching(sender: AnyObject) {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "clusterSwitching"])
        delegate?.clusterSwitcher.change()
    }
    
    @objc func restorePurchase() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "Restore purchase"])
        restore()
    }
    
    @objc func presentMail() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "SendMail"])
        presentErrorMailReport()
    }
    
    @objc func attempUpdate() {
        navigationItem.title = "\("Updating".localize())..."
        refreshButton?.rotate360Degrees()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dataUpdate), userInfo: nil, repeats: false)
    }
    
    @objc func dataUpdate() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "Data update"])
        print("\n*** data reflash ***\n")
        
        DataManager.fetchData { (_) in
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.navigationItem.title = "Information".localize()
                self.timer = nil
            }
        }
        //        delegate?.getAnnotationFromRemote {
        //            DispatchQueue.main.async {
        //                self.collectionView?.reloadData()
        //                self.navigationItem.title = "Information".localize()
        //                self.timer = nil
        //            }
        //        }
    }
}


// MARK: - in-App purchase process

extension MenuController: IAPPurchasable {
    
    fileprivate func setupPurchaseItem() {
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) { return }
        setupObserver()
        getInfo(.removeAds) { (success, products) in
            if success, let products = products {
                self.products = products
            }
        }
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        print("MenuController recieved notify")
        DispatchQueue.main.async { self.collectionView?.reloadData() }
    }
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: .removeAds,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: .manuContent,
                                               object: nil)
        
    }
    
}




