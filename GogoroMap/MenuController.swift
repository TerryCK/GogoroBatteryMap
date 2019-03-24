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
    var clusterSwitcher: ClusterStatus { set get }
    func dataUpdate(onCompletion: (() -> Void)?)
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
        NotificationCenter.default.removeObserver(self, name: .init(rawValue: Keys.standard.removeAdsObserverName), object: nil)
    }
    
    // MARK: - CollectionView logics
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: type(of: self)), for: indexPath) as! StationsViewCell
        
        cell.delegate = self
        cell.analytics = StationAnalyticsModel(dataSource?.batteryStationPointAnnotations ?? [])
        cell.product = products.first
        cell.purchaseHandler = purchase
        
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            cell.buyStoreButtonStackView.isHidden = true
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
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        collectionView?.isScrollEnabled = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.register(StationsViewCell.self, forCellWithReuseIdentifier: String(describing: type(of: self)))
    }
    
    // MARK: - Events
    private func open(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
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
        log(#function)
        let head = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="
        let foot = "&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
        let url = head + Keys.standard.appID + foot
        open(url: url)
    }
    
    @objc func moreApp() {
        log(#function)
        open(url: "https://itunes.apple.com/tw/app/id1192891004?l=zh&mt=8")
    }
    
    @objc func shareThisApp() {
        log(#function)
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
        log(#function)
        delegate?.clusterSwitcher.change()
    }
    
    @objc func restorePurchase() {
        log(#function)
        restore()
    }
    
    @objc func presentMail() {
        log(#function)
        presentErrorMailReport()
    }

    @objc func attempUpdate() {
        log(#function)
        navigationItem.title = "\("Updating".localize())..."
        refreshButton?.rotate360Degrees()
        refreshButton?.isUserInteractionEnabled = false
        delegate?.dataUpdate { [weak self] in
            DispatchQueue.main.async {
                self?.navigationItem.title = "Information".localize()
                self?.collectionView?.reloadData()
                self?.refreshButton?.isUserInteractionEnabled = true
            }
        }
    }
    
    private func log(_ event: String) {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: event])
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
        DispatchQueue.main.async { self.collectionView?.reloadData() }
    }
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: .init(rawValue: Keys.standard.removeAdsObserverName),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: .init(rawValue: Keys.standard.manuContentObserverName),
                                               object: nil)
        
    }
    
}




