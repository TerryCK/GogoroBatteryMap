//
//  StationsViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/11.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import StoreKit

typealias PurchaseFunc = (_ product: SKProduct) -> ()

protocol StationsViewCellDelegate: class { }


final class StationsViewCell: BaseCollectionViewCell {
    
    weak var delegate: StationsViewCellDelegate? {
        didSet {
            guideButton.addTarget(delegate, action: .performGuidePage(), for: .touchUpInside)
            feedBackButton.addTarget(delegate, action: .presentMail(), for: .touchUpInside)
            recommandButton.addTarget(delegate, action: .recommand(), for: .touchUpInside)
            shareButton.addTarget(delegate, action: .shareThisApp(), for: .touchUpInside)
            moreAppsButton.addTarget(delegate, action: .moreApp(), for: .touchUpInside)
            dataUpdateButton.addTarget(delegate, action: .attempUpdate(), for: .touchUpInside)
        }
    }
    
    var stationData: StationDatas = (0,0,0,0) {
        didSet {
            availableLabel.text = "\(NSLocalizedString("Opening:", comment: "")) \(stationData.available)"
            buildingLabel.text = "\(NSLocalizedString("Building:", comment: "")) \(stationData.total - stationData.available)"
            haveBeenLabel.text = "\(NSLocalizedString("Have been:", comment: "")) \(stationData.hasFlags)"
            completedRatioLabel.text = "\(NSLocalizedString("Completed ratio:", comment: "")) \(completedPercentage) %"
            hasCheckinsLabel.text = "\(NSLocalizedString("Total checkins:", comment: "")) \(stationData.hasCheckins)"
             //            totleLabel.text = "\(NSLocalizedString("Total:", comment: "")) \(stationData.totle)"
        }
    }
    
    private var completedPercentage: String {
        get {
            return (Double(stationData.hasFlags) / Double(stationData.available)).percentage
        }
    }
    
    var product: SKProduct? {
        didSet {
            removeAdsButton.setTitle("\(product?.localizedPrice ?? "error") \n\(product?.localizedTitle ?? "error")", for: .normal)
            if let index = buttonsStackView.subviews.index(of: copyrightLabel) {
                restoreButton.addTarget(delegate, action: .restorePurchase(), for: .touchUpInside)
                removeAdsButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
                buttonsStackView.insertArrangedSubview(buyStoreButtonStackView, at: index)
                layoutIfNeeded()
            }
        }
    }
    
    
    var purchaseHandler: (PurchaseFunc)?
    
    @objc func buyButtonTapped() {
        if let product = product, let purchaseing = purchaseHandler {
            purchaseing(product)
        }
    }
    
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
    
    private lazy var hasBeenList: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 5
        return button
    }()
    
    private lazy var authorLabel: UILabel = {     
        let label = UILabel()
        label.text = "Chen, Guan-Jhen 2017 Copyright"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
        }()
    
    private lazy var availableLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
        }()
    
    private lazy var haveBeenLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Have been:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private lazy var hasCheckinsLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Total checkins:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }() 
    
    private lazy var completedRatioLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("completed ratio", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
        }()
    
    private lazy var totleLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Total:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
        }()
    
    private lazy var buildingLabel: UILabel = {     
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Building:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
        }()
    
    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Data provided by Gogoro, image: CC0 Public Domain", comment: "")
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
    
    private lazy var dataUpdateButton: UIButton = {
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
    
    private let guideButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Guide", comment: ""), for: .normal)
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
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [self.lastUpdateDateLabel, self.dataUpdateButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var pushShareStackView: UIStackView = {     
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [self.shareButton, self.recommandButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var feedBackButtonStackView: UIStackView = {     
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [self.guideButton, self.feedBackButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
     lazy var buyStoreButtonStackView: UIStackView = {     
        let stackView = UIStackView(arrangedSubviews:  [self.restoreButton, self.removeAdsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var operationStatusStack: UIStackView = {     
        let stackView = UIStackView(arrangedSubviews:  [self.availableLabel, self.buildingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var headStackView: UIStackView = {     
        let stackView = UIStackView(arrangedSubviews: [self.updateStackView, self.completedRatioLabel, self.haveBeenLabel, self.hasCheckinsLabel, self.operationStatusStack])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
        }()
    
    private lazy var buttonsStackView: UIStackView = {
        var subviews: [UIView] = [self.pushShareStackView, self.feedBackButtonStackView,  self.copyrightLabel]
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var bottomLabelStackView: UIStackView = {     
        let stackView = UIStackView(arrangedSubviews: [self.copyrightLabel ,self.authorLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
        }()
    
    func setupThanksLabel() {
        buttonsStackView.insertArrangedSubview(thanksLabel, at: 0)
    }
    
    deinit {
        print("station view cell deinitialize")
    }

    override func setupViews() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        viewContainer.addSubview(headStackView)
        
        headStackView.anchor(top: viewContainer.topAnchor, left: viewContainer.leftAnchor, bottom: nil, right: viewContainer.rightAnchor, topPadding: 10, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 200)
        
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
}
