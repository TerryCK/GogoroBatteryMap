//
//  DetailAnnotationView.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/22.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class DetailAnnotationView: UIView {
    // MARK: - View creators
    let goButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "go").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        return button
    }()
    
    let checkinButton: UIButton = {
        let button = CheckinButton(type: .system)
        return button
    }()
    
    let unCheckinButton: UIButton = {
        let button = UnCheckInButton(type: .system)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [checkinButton, unCheckinButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private let addressTextView = UITextView {
        $0.text = "地址"
        $0.isEditable = false
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 12)
    }
    
    let etaLabel = UILabel {
        $0.text = "約需：120 分鐘"
        $0.font = .systemFont(ofSize: 11)
    }
    
    let distanceLabel = UILabel {
        $0.text = "100 km"
        $0.font = .systemFont(ofSize: 12)
    }
    
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
    
    let lastCheckTimeLabel = UILabel {
        $0.text = "最近的打卡日："
        $0.font = .systemFont(ofSize: 12)
    }
    
    let timesOfCheckinLabel = UILabel {
        $0.text = "打卡： 0  次"
        $0.font = .systemFont(ofSize: 12)
    }
    
    private let isAvailableLabel = UILabel {
        $0.text = "關閉中"
        $0.backgroundColor = .lightGray
        $0.textColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 9)
        $0.anchor(top: nil, left: nil, bottom: nil, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 40, height: 12)
    }
    
    private let opneHourLabel = UILabel {
        $0.text = "營業時間：24hr"
        $0.font = .systemFont(ofSize: 12)
    }
    
    private lazy var openStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [opneHourLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    
    private lazy var mainStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [isAvailableLabel, openStackView, timesOfCheckinLabel,  lastCheckTimeLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalCentering
        stackView.spacing = 6
        return stackView
    }()
    
    private let separatorView = UIView {
        $0.backgroundColor = .lightGray
    }
    
    
    //    MARK: - View's setup & initialize with autolayout
    private func setup() {
        [goButtonStackView, mainStackView, addressTextView, buttonStackView, separatorView].forEach(addSubview)
        
        separatorView.anchor(top: goButtonStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 10, leftPadding: 5, bottomPadding: 0, rightPadding: 5, width: 0, height: 0.75)
        
        goButtonStackView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 10, bottomPadding: 0, rightPadding: 10, width: 0, height: 40)
        
        mainStackView.anchor(top: goButtonStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 20, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 72)
        
        addressTextView.anchor(top: mainStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 50)
        
        buttonStackView.anchor(top: nil, left: mainStackView.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 35)
        
    }
    
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        anchor(top: nil, left: nil, bottom: nil, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 170, height: 210)
        setup()
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with counterOfcheckin: Int) {
        unCheckinButton.isHidden = counterOfcheckin <= 0
        lastCheckTimeLabel.text =  "最近的打卡日：\(counterOfcheckin > 0 ? Date.today : "")"
        timesOfCheckinLabel.text = "打卡：\(counterOfcheckin) 次"
        layoutIfNeeded()
    }
    
    func configure(annotation: BatteryStationPointAnnotation) -> Self {
        opneHourLabel.text = "\(annotation.subtitle ?? "")"
        addressTextView.text = "地址：\(annotation.address)"
        timesOfCheckinLabel.text = "打卡：\(annotation.checkinCounter ?? 0) 次"
        lastCheckTimeLabel.text = "最近的打卡日：\(annotation.checkinDay ?? "")"
        
        unCheckinButton.isHidden = (annotation.checkinCounter ?? 0) <= 0
        
        if annotation.state == 1 {
            isAvailableLabel.text = "營運中"
            isAvailableLabel.backgroundColor = .lightGreen
            checkinButton.isEnabled = true
        }
        return self
    }
}



