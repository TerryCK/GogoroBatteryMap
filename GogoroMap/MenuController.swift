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

final class MenuController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellid = "cellid"
    let appID = Keys.standard.appID
    
    weak var delegate: ManuDelegate?
    
    var timer: Timer?
    
    var products = [SKProduct]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
//    private lazy var viewContainer: UIView = { [unowned self] in
//        
//        let containerView = UIView()
//        
//        let blurEffect = UIBlurEffect(style: .extraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = self.view.bounds
//        blurEffectView.alpha = 0.85
//        
//        self.view.addSubview(blurEffectView)
//        
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//        
//        vibrancyEffectView.frame = self.view.bounds
//        blurEffectView.contentView.addSubview(vibrancyEffectView)
//        
//        
//        let vibrancyEffectContentView = vibrancyEffectView.contentView
//        vibrancyEffectContentView.addSubview(containerView)
//        
//        containerView.anchor(top: vibrancyEffectContentView.topAnchor, left: vibrancyEffectContentView.leftAnchor, bottom: vibrancyEffectContentView.bottomAnchor, right:  vibrancyEffectContentView.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
//        
//        return containerView
//        }()
    
    
//    let boardView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .red
//        return view
//    }()
//
//    func setupView() {
////        view.addSubview(boardView)
////        boardView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: 10, leftPadding: 10, bottomPadding: 0, rightPadding: 10, width: 0, height: 150)
////        view.addSubview(collectionView!)
////        collectionView?.anchor(top: boardView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviagtionAndCollectionView()
        setupPurchaseItem()
//        setupView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "Menu Page", contentType: nil, contentId: nil, customAttributes: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as? StationsViewCell else { return StationsViewCell() }
        
        if let stationData = delegate?.stationData {
            cell.stationData = stationData
        }
        
        cell.menuController = self
        
        if !self.products.isEmpty {
            cell.product = self.products.first
        }
        
        cell.purchaseHandler = { product in
            self.purchase(product)
        }
        
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            cell.buyStoreButtonStackView.removeFromSuperview()
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
    
    
    func performGuidePage() {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Guide"])
        present(GuidePageViewController(), animated: true, completion: nil)
    }
    
    func recommand() {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Recommand"])
        let head = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="
        let foot = "&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
        let url = head + appID + foot
        open(url: url)
    }
    
    func moreApp() {
        Answers.logCustomEvent(withName: Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "MoreApp"])
        open(url: "https://itunes.apple.com/tw/app/id1192891004?l=zh&mt=8")
    }
    
    func shareThisApp() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [ Log.sharedName.manuButton: "Share"])
        guard let name = NSURL(string: "https://itunes.apple.com/tw/app/id\(appID)?l=zh&mt=8") else { return }
        let activityVC = UIActivityViewController(activityItems: [name], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func restorePurchase() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "Restore purchase"])
        restore()
    }
    
    func presentMail() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "SendMail"])
        presentErrorMailReport()
    }
    
     func attempUpdate() {
        navigationItem.title = "\(NSLocalizedString("Updating", comment: ""))..."
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dataUpdate), userInfo: nil, repeats: false)
    }
    
    func dataUpdate() {
        Answers.logCustomEvent(withName:  Log.sharedName.manuButtons, customAttributes: [Log.sharedName.manuButton: "Data update"])
        print("\nreflash\n")
        delegate?.getAnnotationFromRemote { [unowned self] in
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.navigationItem.title = NSLocalizedString("Information", comment: "")
            }
        }
    }
    
   

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
    
    private func open(url: String) {
        guard let checkURL = URL(string: url),
            UIApplication.shared.canOpenURL(checkURL) else { return }
        UIApplication.shared.openURL(checkURL)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NotificationName.shared.removeAds, object: nil)
        print("menu controller deinitialize")
    }
    
    
}


// MARK: in-App purchase thing

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
    
    func handlePurchaseNotification(_ notification: Notification) {
        print("MenuController recieved notify")
        collectionView?.reloadData()
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




