//
//  UnCheckInButton.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/22.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

class UnCheckInButton: CustomButton {
    var mainColor: UIColor {  return .lightRed }
    let slaveColor = UIColor.white

   override func setup() {
        backgroundColor = mainColor
        tintColor = slaveColor
        layer.borderWidth = 3
        layer.borderColor = mainColor.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true
        setTitle("移除打卡", for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? slaveColor : mainColor
            tintColor = isHighlighted ? mainColor : slaveColor
        }
    }
}
