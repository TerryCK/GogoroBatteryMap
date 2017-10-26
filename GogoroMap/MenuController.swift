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

protocol ManuDelegate: class {
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    var  stationData: StationDatas { get }
}

final class MenuController: UICollectionViewController, UICollectionViewDelegateFlowLayout, StationsViewCellDelegate {
    // MARK: - Properties
    let cellid = "cellid"
    
    
    weak var delegate: ManuDelegate?
    
    var timer: Timer?
    
    var products = [SKProduct]() {
        didSet { collectionView?.reloadData()  }
    }
    // MARK: - ViewController life cycles
    override func loadView() {
        super.loadView()
        setupNaviagtionAndCollectionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPurchaseItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "Menu Page", contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotificationName.shared.removeAds, object: nil)
        print("menu controller deinitialize")
    }
    
    // MARK: - CollectionView logics
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as? StationsViewCell ?? StationsViewCell()
        
        cell.delegate = self
        
        if let stationData = delegate?.stationData {
            cell.stationData = stationData
        }
        
        if !self.products.isEmpty {
            cell.product = self.products.first
        }
        
        cell.purchaseHandler = { product in
            self.purchase(product)
        }
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            cell.buyStoreButtonStackView.removeFromSuperview()
            cell.setupThanksLabel()
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20 , height: view.frame.height - 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
 
    // MARK: - Setup & initializing Views
    private func setupNaviagtionAndCollectionView() {
        
        navigationController?.view.layer.cornerRadius = 10
        navigationController?.view.layer.masksToBounds = true
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = NSLocalizedString("Information", comment: "")
        navigationItem.titleView?.layer.cornerRadius = 10
        navigationItem.titleView?.layer.masksToBounds = true
        
        collectionView?.backgroundColor = .clear
        collectionView?.contentInset = UIEdgeInsetsMake( 10, 0, 10, 0)
        
        //        if let collectionLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        //            collectionLayout.sectionInset = UIEdgeInsets(top: 50, left: 10, bottom: 10, right: 10)
        //        }
        
        collectionView?.isScrollEnabled = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.register(StationsViewCell.self, forCellWithReuseIdentifier: cellid)
    }
    
    // MARK: - Events
    private func open(url: String) {
        guard let checkURL = URL(string: url),
            UIApplication.shared.canOpenURL(checkURL) else { return }
        UIApplication.shared.openURL(checkURL)
    }
    
   
    
    
}

// MARK: - Perform target's events
extension MenuController {
    
    @objc func performGuidePage() {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Guide"])
        present(GuidePageViewController(), animated: true, completion: nil)
    }

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
        guard let name = NSURL(string: "https://itunes.apple.com/tw/app/id\(Keys.standard.appID)?l=zh&mt=8") else { return }
        let activityVC = UIActivityViewController(activityItems: [name], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(activityVC, animated: true, completion: nil)
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
        navigationItem.title = "\(NSLocalizedString("Updating", comment: ""))..."
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dataUpdate), userInfo: nil, repeats: false)
    }
    
    @objc func dataUpdate() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "Data update"])
        print("\n data reflash\n")
        delegate?.getAnnotationFromRemote {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.navigationItem.title = NSLocalizedString("Information", comment: "")
                self.timer = nil
            }
        }
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
                                               name: NotificationName.shared.removeAds,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: NotificationName.shared.manuContent,
                                               object: nil)
        
    }
    
}




