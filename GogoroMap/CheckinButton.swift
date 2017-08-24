//
//  checkinButton.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/22.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class CheckinButton: UIButton {
    
    let mainColor = UIColor.grassGreen
    let slaveColor = UIColor.white
    let unableColor = UIColor.lightGray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        backgroundColor = mainColor
        tintColor = slaveColor
        layer.borderWidth = 3
        layer.cornerRadius = 5
        layer.masksToBounds = true
        isEnabled = false
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? slaveColor : mainColor
            tintColor = isHighlighted ? mainColor : slaveColor
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        }
    }
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? mainColor : unableColor
            tintColor = slaveColor
            let title = isEnabled ? "打  卡" : "關閉中"
            setTitle(title, for: .normal)
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            layer.borderColor = isEnabled ? mainColor.cgColor : unableColor.cgColor

        }
    }
    
    
}
