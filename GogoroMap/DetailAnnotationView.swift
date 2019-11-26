//
//  DetailAnnotationView.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/22.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class DetailAnnotationView: UIView {
    
    let goButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "go").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.tag = ButtonAction.go.rawValue
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    enum ButtonAction: Int {
        case go = 0, checkin = 1, uncheckin = 2
    }
    
    @objc func buttonPressed(sender: UIButton) {
        guard let action = ButtonAction(rawValue: sender.tag) else {
            return
        }
        switch action {
        case .go: goAction?()
        case .checkin: checkinAction?()
        case .uncheckin: uncheckinAction?()
        }
    }
    
    var goAction : (() -> Void)?
    var checkinAction  :  (() -> Void)?
    var uncheckinAction:  (() -> Void)?
    
    let checkinButton: UIButton = {
        $0.tag = ButtonAction.checkin.rawValue
        $0.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return $0
    }(CheckinButton(type: .system))
    
    let unCheckinButton: UIButton = {
        $0.isHidden = true
        $0.tag = ButtonAction.uncheckin.rawValue
        $0.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return $0
    }(UnCheckInButton(type: .system))
    
    lazy var buttonStackView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [checkinButton, unCheckinButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private let addressLabel = UILabel {
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 12)
        $0.backgroundColor = .clear
        $0.numberOfLines = 0
    }
    
    let etaLabel = UILabel {  $0.font = .systemFont(ofSize: 11) }
    
    let distanceLabel = UILabel {  $0.font = .systemFont(ofSize: 12)  }
    
    private lazy var etaStackview: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [distanceLabel, etaLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    

    private lazy var goButtonStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [goButton, etaStackview])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    
    let timesOfCheckinLabel = UILabel {  $0.font = .systemFont(ofSize: 12)  }
    
    private let isAvailableLabel = UILabel {
        $0.textColor = .white
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.baselineAdjustment = .alignCenters
        $0.font = .systemFont(ofSize: 12)
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    private let opneHourLabel = UILabel { $0.font = .systemFont(ofSize: 12) }
    
    private lazy var openStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [isAvailableLabel, opneHourLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    
    private lazy var mainStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [openStackView, timesOfCheckinLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalCentering
        stackView.spacing = 6
        return stackView
    }()
    
    private let separatorView = UIView { $0.backgroundColor = .lightGray }
    
    //    MARK: - View's setup & initialize with autolayout
    private func setup() {
        let views = [goButtonStackView, mainStackView, addressLabel, nativeAdView, buttonStackView, separatorView]
        for case let view? in views {
            addSubview(view)
        }
        
        separatorView.anchor(top: goButtonStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 10, leftPadding: 5, bottomPadding: 0, rightPadding: 5, width: 0, height: 0.75)
        
        goButtonStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 10, bottomPadding: 0, rightPadding: 10, width: 0, height: 0)
        
        mainStackView.anchor(top: separatorView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 10, leftPadding: 5, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        addressLabel.anchor(top: mainStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 5, leftPadding: 10, bottomPadding: 10, rightPadding: 10, width: 0, height: 0)
        
        
        nativeAdView?.anchor(top: addressLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 5, height: 32)
        buttonStackView.anchor(top: (nativeAdView ?? addressLabel).bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPadding: 5)
        
        widthAnchor.constraint(lessThanOrEqualToConstant: 210).isActive = true
        backgroundColor = .clear
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let nativeAdView: GADUnifiedNativeAdView? = {
        guard !UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) else {
            return nil
        }
        guard let nibObjects = Bundle.main.loadNibNamed("AdLabel", owner: nil, options: nil),
            let adView = nibObjects.first as? GADUnifiedNativeAdView else {
                return nil
        }
        adView.translatesAutoresizingMaskIntoConstraints = false
        return adView
    }()
    
    
    @discardableResult
    func configure(annotation: BatteryStationPointAnnotation) -> Self {
        if let nativeAd = UIApplication.mapViewController?.nativeAd {
            nativeAdView?.nativeAd = nativeAd
            (nativeAdView?.bodyView as? UILabel)?.text = nativeAd.body
        }
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            nativeAdView?.removeFromSuperview()
        }
        
        opneHourLabel.text = "\(annotation.subtitle ?? "")"
        addressLabel.text = "地址：\(annotation.address)"
        checkinButton.isEnabled = annotation.isOperating
        isAvailableLabel.backgroundColor = annotation.isOperating ? .lightGreen : .lightGray
        isAvailableLabel.text = annotation.isOperating ? " 營運中 " : " 敬請期待 "
        if let counterOfcheckin = annotation.checkinCounter,
            counterOfcheckin > 0,
            let checkindate = annotation.checkinDay?.string(dateformat: "yyyy.MM.dd") {
            timesOfCheckinLabel.text = "打卡：\(counterOfcheckin) 次,  打卡日： \(checkindate)"
            unCheckinButton.isHidden = false
        } else {
            unCheckinButton.isHidden = true
            timesOfCheckinLabel.text = "   "
        }
        return self
    }
}



