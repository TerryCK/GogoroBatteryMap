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
import GoogleMobileAds

protocol ManuDelegate: AnyObject {
    
    var clusterSwitcher: ClusterStatus { set get }
    var nativeAd: GADUnifiedNativeAd? { get }
}

final class MenuController: UICollectionViewController, ViewTrackable {
    
    weak var delegate: ManuDelegate?
    
    var refreshButton: UIButton?
    
    var products = [SKProduct]() {
        didSet { collectionView?.reloadData()  }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviagtionAndCollectionView()
        setupPurchaseItem()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard Environment.environment == .release, #available(iOS 10.3, *) else { return }
            SKStoreReviewController.requestReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Answers.logContentView(withName: "Menu Page", contentType: nil, contentId: nil, customAttributes: nil)
        if self.refreshButton?.isUserInteractionEnabled == .some(false) {
            self.refreshButton?.rotate360Degrees()
        }
    }

    // MARK: - CollectionView logics
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: type(of: self)), for: indexPath) as! StationsViewCell
        
        cell.delegate = self
        cell.analytics = StationAnalyticsModel(DataManager.shared.originalStations)
        cell.product = products.first
        cell.purchaseHandler = purchase
        cell.mapOptions.setTitle("導航：" + Navigator.option.description, for: .normal)
        
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            cell.buyStoreButtonStackView.isHidden = true
            cell.setupThanksLabel()
            cell.nativeAdView?.removeFromSuperview()
        } else {
            cell.nativeAdView?.nativeAd = delegate?.nativeAd
            (cell.nativeAdView?.bodyView as? UILabel)?.text = delegate?.nativeAd?.body
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
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView?.isScrollEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.register(StationsViewCell.self, forCellWithReuseIdentifier: String(describing: type(of: self)))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: - Events
    private func open(url: String) {
        URL(string: url).map { if #available(iOS 10.0, *) {
            UIApplication.shared.open($0)
        } else {
            UIApplication.shared.openURL($0)
            } }
    }
}

// MARK: - Perform target's events
extension MenuController {
    
    @objc func performBackupPage() {
        navigationController?.pushViewController(BackupViewController(style: .grouped), animated: true)
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
//        open(url: "https://apple.co/2KqUHIy")
        open(url: "https://apps.apple.com/tw/developer/chen-guan-jhen/id1168936144")
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
    
    @objc func changeMapOption(sender: UIButton) {
        let alertController = UIAlertController(title: "導航選項", message: "選擇偏好的導航地圖", preferredStyle: .actionSheet)
        var actions = Navigator.Option.allCases.map { option in
            UIAlertAction(title: option.description,
                          style: .default,
                          handler: { _ in
                            Navigator.option = option
                            self.collectionView.reloadData()
            })
        }
        actions.append(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actions.forEach(alertController.addAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sender
        }
        present(alertController, animated: true)
    }
    
    @objc func attempUpdate() {
        log(#function)
        navigationItem.title = "\("Updating".localize())..."
        refreshButton?.rotate360Degrees()
        refreshButton?.isUserInteractionEnabled = false
        
        DataManager.shared.fetchStations {
            DispatchQueue.main.async {
                self.navigationItem.title = "Information".localize()
                self.collectionView?.reloadData()
                self.refreshButton?.isUserInteractionEnabled = true
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
        getSKProduct(.removeAds) {
            if case .success(let products) = $0 {
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




