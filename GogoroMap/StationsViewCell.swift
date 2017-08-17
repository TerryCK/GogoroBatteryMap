//
//  StationsViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/11.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import StoreKit

final class StationsViewCell: UICollectionViewCell {
    
    weak var menuController: MenuController? {
        
        didSet {
            contactButton.addTarget(menuController, action: #selector(menuController?.presentMail), for: .touchUpInside)
            recommandButton.addTarget(menuController, action: #selector(menuController?.recommand), for: .touchUpInside)
            shareButton.addTarget(menuController, action: #selector(menuController?.shareThisApp), for: .touchUpInside)
            moreAppsButton.addTarget(menuController, action: #selector(menuController?.moreApp), for: .touchUpInside)
            guideButton.addTarget(menuController, action: #selector(menuController?.performGuidePage), for: .touchUpInside)
            restoreButton.addTarget(menuController, action: #selector(menuController?.restorePurchase), for: .touchUpInside)
        }
    }
    
    var stationData: (totle: Int, available: Int) = (0, 0) {
        didSet {
            availableLabel.text = "營運中: \(stationData.available)"
            buildingLabel.text = "建置中: \(stationData.totle - stationData.available)"
            totleLabel.text = "總站數: \(stationData.totle)"
        }
    }
    
    var product: SKProduct? {
        didSet {

            self.buyStoreButtonStackView.addArrangedSubview(removeAdsButton)
            self.restoreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.removeAdsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
            
//            guard let product = product else { return }
//            
//            
//            if Products.store.isProductPurchased(product.productIdentifier) {
//            } else if IAPHelper.canMakePayments() {
//                StationsViewCell.priceFormatter.locale = product.priceLocale
//                self.buyStoreButtonStackView.addArrangedSubview(removeAdsButton)
//                self.restoreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//                self.removeAdsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
//            } else {
//                self.buttonsStackView.willRemoveSubview(self.removeAdsButton)
//            }
//            
//            self.layoutIfNeeded()
        }
    }
    
    
    var buyButtonHandler: ((_ product: SKProduct) -> ())?
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private lazy var authorLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "Chen, Guan-Jhen 2017 Copyright"
        label.font = UIFont.systemFont(ofSize: 11)
        return label
        }()
    
    private lazy var availableLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = "營運中的站點數量："
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private lazy var totleLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = "總站點數量："
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private lazy var buildingLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = "建置中："
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "資料為gogoro所有，僅供查詢使用不保證其資訊正確性，App為作者所有，背景影像授權自：CC0 Public Domain"
        label.font = UIFont.boldSystemFont(ofSize: 9)
        label.numberOfLines = 0
        return label
    }()
    
    
    
    private lazy var lastUpdateDateLabel: UILabel = {
        let label = UILabel()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        let dateString = formatter.string(from: date)
        label.text = "更新日期：" + dateString
        label.font = UIFont.boldSystemFont(ofSize: 10)
        return label
    }()
    
    private let contactButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("聯繫作者", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("分    享", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let recommandButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("給    推", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private lazy var pushShareStackView: UIStackView = { [unowned self] in
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [self.shareButton, self.recommandButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
    private let moreAppsButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("更多同作者app", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let guideButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("功能導覽", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let removeAdsButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("NTD 30\n去廣告", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let restoreButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("恢復購買", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    lazy var buyStoreButtonStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(arrangedSubviews:  [self.restoreButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var labelStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(arrangedSubviews: [self.lastUpdateDateLabel, self.availableLabel, self.buildingLabel, self.totleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
        }()
    
    private lazy var buttonsStackView: UIStackView = { [unowned self] in
        var subviews: [UIView] = [self.pushShareStackView, self.contactButton, self.moreAppsButton, self.guideButton, self.buyStoreButtonStackView]
        
//        if !UserDefaults.standard.bool(forKey: Products.removeAds) {
//            subviews.append(self.buyStoreButtonStackView)
//        }
        
        subviews.append(self.copyrightLabel)
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
        }()
    
    
    
    private lazy var bottomLabelStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(arrangedSubviews: [self.copyrightLabel ,self.authorLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
        }()
    
    
    func buyButtonTapped() {
        if let product = product {
            buyButtonHandler?(product)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    deinit {
        print("station view cell deinitialize")
    }
    
    private lazy var viewContainer: UIView = { [unowned self] in
        
        let containerView = UIView()
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 0.85
        
        self.addSubview(blurEffectView)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        vibrancyEffectView.frame = self.bounds
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        
        let vibrancyEffectContentView = vibrancyEffectView.contentView
        vibrancyEffectContentView.addSubview(containerView)
        
        containerView.anchor(top: vibrancyEffectContentView.topAnchor, left: vibrancyEffectContentView.leftAnchor, bottom: vibrancyEffectContentView.bottomAnchor, right:  vibrancyEffectContentView.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        return containerView
        }()
    
    

    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        viewContainer.addSubview(labelStackView)
        labelStackView.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, topPadding: 10, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 128)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .white
        
        viewContainer.addSubview(separatorView)
        separatorView.anchor(top: labelStackView.bottomAnchor, left:  viewContainer.leftAnchor, bottom: nil, right:  viewContainer.rightAnchor, topPadding: 10, leftPadding: 10, bottomPadding: 0, rightPadding: 10, width: 0, height: 0.75)
        
        
        viewContainer.addSubview(authorLabel)
        authorLabel.anchor(top: nil, left: nil, bottom: viewContainer.bottomAnchor, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 10, rightPadding: 0, width: 0, height: 20)
        authorLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor).isActive = true
        
        viewContainer.addSubview(buttonsStackView)
        buttonsStackView.anchor(top: separatorView.bottomAnchor, left: viewContainer.leftAnchor, bottom: authorLabel.topAnchor, right: viewContainer.rightAnchor, topPadding: 16, leftPadding: 20, bottomPadding: 0, rightPadding: 20, width: 0, height: 0)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
