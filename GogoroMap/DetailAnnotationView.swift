//
//  DetailAnnotationView.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/22.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class DetailAnnotationView: UIView {
     
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
        let stackView:  UIStackView = UIStackView(arrangedSubviews: [self.checkinButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        
        return stackView
        }()
    
    private let addressTextView: UITextView = {
        let textField = UITextView()
        
        textField.text = "地址：彰化縣鹿港鎮鹿東路52之192號"
        textField.isEditable = false
        textField.textColor = .lightGray
        textField.font = UIFont.systemFont(ofSize: 10)
        return textField
    }()
    
    let etaLabel: UILabel = {
        let label = UILabel()
        label.text = "約需：120 分鐘"
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "100 km"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var etaStackview: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [self.distanceLabel, self.etaLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
        }()
    
    private lazy var goButtonStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [self.goButton, self.etaStackview])
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
        }()
    
    
    
    
    let lastCheckTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "最近的打卡日："
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let timesOfCheckinLabel: UILabel = {
        let label = UILabel()
        label.text = "打卡： 0  次"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let isAvailableLabel: UILabel = {
        let label = UILabel()
        label.text = "關閉中"
        label.backgroundColor = .lightGray
        label.textColor = .white
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 9)
        label.anchor(top: nil, left: nil, bottom: nil, right: nil, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 40, height: 12)
        return label
    }()
    
    private let opneHourLabel: UILabel = {
        let label = UILabel()
        label.text = "營業時間：24hr"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var openStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [self.opneHourLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
        }()
    
    
    private lazy var mainStackView: UIStackView = {   
        let stackView: UIStackView = UIStackView(arrangedSubviews: [self.isAvailableLabel, self.openStackView, self.timesOfCheckinLabel,  self.lastCheckTimeLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalCentering
        stackView.spacing = 6
        return stackView
        }()
    
    private let separatorView: UIView = {
        let view = UIView ()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private func setup() {
        addSubview(goButtonStackView)
        addSubview(mainStackView)
        addSubview(addressTextView)
        addSubview(buttonStackView)
        addSubview(separatorView)
        
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
    
    
    init(with annotation: CustomPointAnnotation) {
        self.init()
        
        if annotation.isOpening {
            self.isAvailableLabel.text = "營運中"
            self.isAvailableLabel.backgroundColor = .lightGreen
            self.checkinButton.isEnabled = true
            
        }
        
        self.opneHourLabel.text = "\(annotation.subtitle ?? "")"
        self.addressTextView.text = "地址：\(annotation.address)"
        self.timesOfCheckinLabel.text = "打卡：\(annotation.checkinCounter) 次"
        self.lastCheckTimeLabel.text = "最近的打卡日：\(annotation.checkinDay)"
        if annotation.checkinCounter > 0 {
            self.buttonStackView.addArrangedSubview(unCheckinButton)
        }
    }
}



