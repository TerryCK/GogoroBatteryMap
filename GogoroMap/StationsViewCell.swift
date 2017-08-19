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
            dataUpdateButton.addTarget(menuController, action: #selector(menuController?.dataUpdate), for: .touchUpInside)
            
        }
    }
    
    var stationData: (totle: Int, available: Int) = (0, 0) {
        didSet {
            
            availableLabel.text = "\(NSLocalizedString("Opening:", comment: "")) \(stationData.available)"
            buildingLabel.text = "\(NSLocalizedString("Building:", comment: "")) \(stationData.totle - stationData.available)"
            totleLabel.text = "\(NSLocalizedString("Total:", comment: "")) \(stationData.totle)"
        }
    }
    
    var product: SKProduct? {
        didSet {
            if let index = buttonsStackView.subviews.index(of: copyrightLabel) {
                restoreButton.addTarget(menuController, action: #selector(menuController?.restorePurchase), for: .touchUpInside)
                removeAdsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
                buttonsStackView.insertArrangedSubview(buyStoreButtonStackView, at: index)
                layoutIfNeeded()
            }
            
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
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private lazy var totleLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Total:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private lazy var buildingLabel: UILabel = { [unowned self] in
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Building:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Data provided by Gogoro, image: CC0 Public Domain", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 9)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dataUpdateButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("refresh", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        return button
    }()
    
    
    private lazy var updateStackView: UIStackView = { [unowned self] in
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [self.lastUpdateDateLabel, self.dataUpdateButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
        }()
    
    
    private lazy var lastUpdateDateLabel: UILabel = {
        let label = UILabel()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateString = formatter.string(from: date)
        label.text = "\(NSLocalizedString("Last:", comment: "")) " + dateString
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    private let contactButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("FeedBack", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let recommandButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Rating", comment: ""), for: .normal)
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
        button.setTitle("\(NSLocalizedString("More", comment: "")) app", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let guideButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Guide", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let removeAdsButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("NTD 30\n\(NSLocalizedString("RemovedAD", comment: ""))", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let restoreButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Restore", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    lazy var buyStoreButtonStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(arrangedSubviews:  [self.restoreButton, self.removeAdsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var headStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(arrangedSubviews: [self.updateStackView, self.availableLabel, self.buildingLabel, self.totleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
        }()
    
    private lazy var buttonsStackView: UIStackView = { [unowned self] in
        var subviews: [UIView] = [self.pushShareStackView, self.contactButton, self.moreAppsButton, self.guideButton, self.copyrightLabel]
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
        
        viewContainer.addSubview(headStackView)
        headStackView.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, topPadding: 10, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 128)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .white
        
        viewContainer.addSubview(separatorView)
        separatorView.anchor(top: headStackView.bottomAnchor, left:  viewContainer.leftAnchor, bottom: nil, right:  viewContainer.rightAnchor, topPadding: 10, leftPadding: 10, bottomPadding: 0, rightPadding: 10, width: 0, height: 0.75)
        
        
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
