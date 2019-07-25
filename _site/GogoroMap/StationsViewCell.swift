//
//  StationsViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/11.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import StoreKit

final class StationsViewCell: BaseCollectionViewCell {
    
    weak var delegate: MenuController? {
        didSet {
            guideButton.addTarget(delegate, action: #selector(MenuController.performBackupPage), for: .touchUpInside)
            feedBackButton.addTarget(delegate, action: #selector(MenuController.presentMail), for: .touchUpInside)
            recommandButton.addTarget(delegate, action: #selector(MenuController.recommand), for: .touchUpInside)
            shareButton.addTarget(delegate, action: #selector(MenuController.shareThisApp), for: .touchUpInside)
            moreAppsButton.addTarget(delegate, action: #selector(MenuController.moreApp), for: .touchUpInside)
            dataUpdateButton.addTarget(delegate, action: #selector(MenuController.attempUpdate), for: .touchUpInside)
            mapOptions.addTarget(delegate, action: #selector(MenuController.changeMapOption), for: .touchUpInside)
            clusterSwitcher.addTarget(delegate, action: #selector(MenuController.clusterSwitching(sender:)), for: .valueChanged)
        }
    }
    
    var analytics: StationAnalyticsModel = .init(total: 0, availables: 0, flags: 0, checkins: 0) {
        didSet {
            buildingLabel.text = "\("Building:".localize()) \(analytics.buildings)"
            haveBeenLabel.text = "\("Have been:".localize()) \(analytics.flags)"
            availableLabel.text = "\("Opening:".localize()) \(analytics.availables)"
            hasCheckinsLabel.text = "\("Total checkins:".localize()) \(analytics.checkins)"
            completedRatioLabel.text = "\("Completed ratio:".localize()) \(analytics.completedPercentage) %"
        }
    }
    
    var product: SKProduct? {
        didSet {
            guard let product = product, let price = product.localizedPrice else { return }
            removeAdsButton.setTitle("\(price) \n\(product.localizedTitle)", for: .normal)
            restoreButton.addTarget(delegate, action: #selector(MenuController.restorePurchase), for: .touchUpInside)
            removeAdsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
            buyStoreButtonStackView.isHidden = false
            layoutIfNeeded()
        }
    }
    
    var purchaseHandler: ((SKProduct) -> ())?
    
    @objc func buyButtonTapped() {
        if let product = product, let purchaseing = purchaseHandler {
            purchaseing(product)
        }
    }
    
    private lazy var lastUpdateDateLabel: UILabel = UILabel {
        $0.text = "\("Last:".localize()) " + Date().string(dateformat: "yyyy.MM.dd")
        $0.font = .boldSystemFont(ofSize: 11)
    }
    
    private lazy var hasBeenList: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        return button
    }()
    
    private var clusterSwitcher = UISwitch { $0.isOn = ClusterStatus() == .on }
    
    
    private lazy var clusterDescribingLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = "Cluster".localize()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    private let authorLabel = UILabel {
        $0.text = "Chen, Guan-Jhen \(Date().string(dateformat: "yyyy")) Copyright"
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    private lazy var availableLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = ""
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private lazy var haveBeenLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = NSLocalizedString("Have been:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var hasCheckinsLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = NSLocalizedString("Total checkins:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var completedRatioLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = NSLocalizedString("Completed ratio:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = NSLocalizedString("Total:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    private lazy var buildingLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: frame.width, height: 16))
        label.text = NSLocalizedString("Building:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "Data provided by Gogoro, image: CC0 Public Domain".localize()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.numberOfLines = 0
        return label
    }()
    
    private let thanksLabel: UILabel = {
        let label = UILabel()
        label.text = "感謝您的贊助，您的贊助將會鼓勵作者開發更多的App，我們非常歡迎有趣的點子來使您生活更美好"
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dataUpdateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let feedBackButton: UIButton = {
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
    
    private let moreAppsButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("\(NSLocalizedString("More", comment: "")) app", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    let mapOptions: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("\(Navigator.option.description)", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private let guideButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Backup", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return button
    }()
    
    private let removeAdsButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("testing", for: .normal)
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
    
    private lazy var updateStackView: UIStackView = {     
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [lastUpdateDateLabel, dataUpdateButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var pushShareStackView: UIStackView = {     
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [shareButton, recommandButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var feedBackButtonStackView: UIStackView = {     
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [guideButton, feedBackButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var mapOptionStackView: UIStackView = {
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [mapOptions])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var clusterIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "cluster")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var buyStoreButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews:  [restoreButton, removeAdsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var clusterView: UIView = {
        let myView = UIView()
        
        [clusterIconImageView, clusterDescribingLabel,
         clusterSwitcher].forEach(myView.addSubview)
        
        clusterIconImageView.anchor(top: myView.topAnchor, left: myView.leftAnchor, bottom: myView.bottomAnchor, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 43, height: 43)
        
        clusterDescribingLabel.anchor(top: myView.topAnchor, left: clusterIconImageView.rightAnchor, bottom: myView.bottomAnchor, right: nil, topPadding: 0, leftPadding: 5, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        clusterSwitcher.anchor(top: myView.topAnchor, left: nil, bottom: myView.bottomAnchor, right: myView.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 25, width: 0, height: 0)
        
        return myView
    }()
    
    private lazy var operationStatusStack: UIStackView = {     
        let stackView = UIStackView(arrangedSubviews:  [availableLabel, buildingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var headStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [updateStackView, completedRatioLabel, haveBeenLabel, hasCheckinsLabel, operationStatusStack, clusterView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        var subviews: [UIView] = [mapOptions,
                                  pushShareStackView,
                                  feedBackButtonStackView,
                                  buyStoreButtonStackView,
                                  copyrightLabel,]
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var bottomLabelStackView: UIStackView = {     
        let stackView = UIStackView(arrangedSubviews: [copyrightLabel, authorLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    func setupThanksLabel() {
        buttonsStackView.insertArrangedSubview(thanksLabel, at: 0)
    }
    
    override func setupViews() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        viewContainer.addSubview(headStackView)
        
        headStackView.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, topPadding: 10, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 200)
        
        let separatorView = UIView { $0.backgroundColor = .gray }
        
        viewContainer.addSubview(separatorView)
        separatorView.anchor(top: headStackView.bottomAnchor, left:  viewContainer.leftAnchor, bottom: nil, right:  viewContainer.rightAnchor, topPadding: 10, leftPadding: 10, bottomPadding: 0, rightPadding: 10, width: 0, height: 0.75)
        
        
        viewContainer.addSubview(authorLabel)
        authorLabel.anchor(top: nil, left: nil, bottom: viewContainer.bottomAnchor, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 10, rightPadding: 0, width: 0, height: 20)
        authorLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor).isActive = true
        
        viewContainer.addSubview(buttonsStackView)
        buttonsStackView.anchor(top: separatorView.bottomAnchor, left: viewContainer.leftAnchor, bottom: authorLabel.topAnchor, right: viewContainer.rightAnchor, topPadding: 16, leftPadding: 20, bottomPadding: 0, rightPadding: 20, width: 0, height: 0)
        
        [totalLabel, thanksLabel, authorLabel, buildingLabel, copyrightLabel, availableLabel, hasCheckinsLabel, haveBeenLabel, lastUpdateDateLabel, completedRatioLabel, clusterDescribingLabel].forEach { $0.textColor = .gray }
        
    }
}
