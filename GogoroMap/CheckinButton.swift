//
//  checkinButton.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/22.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class CheckinButton: UnCheckInButton {
    
    override var mainColor: UIColor { .grassGreen }
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? mainColor : .lightGray
            setTitle(isEnabled ? "打  卡" : "敬請期待", for: .normal)
            layer.borderColor = isEnabled ? mainColor.cgColor : UIColor.lightGray.cgColor
        }
    }
}
