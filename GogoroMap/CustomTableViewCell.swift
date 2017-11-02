//
//  CustomTableViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 02/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit

class CustomTableViewCell: BasicTableViewCell {

    override func setupViews() {
        super.setupViews()
        setupSwitchButton()
        selectionStyle = .none
    }
    
    func setupSwitchButton() {
        addSubview(switchButton)
        switchButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 44, width: 72, height: 0)
        switchButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: switchButton.leftAnchor, topPadding: 0, leftPadding: 20, bottomPadding: 0, rightPadding: 6, width: 0, height: 0)
        
    }
    
    lazy var switchButton: UISwitch = {
        let mySwitchButton = UISwitch()
            mySwitchButton.isOn = false
            return mySwitchButton
    }()
    
    lazy var titleLabel: UILabel = {
       let myLabel = UILabel()
        myLabel.text = "Cell title Label"
        myLabel.font = UIFont.systemFont(ofSize: 18)
        return myLabel
    }()
}
