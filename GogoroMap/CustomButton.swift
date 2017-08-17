//
//  customButton.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
