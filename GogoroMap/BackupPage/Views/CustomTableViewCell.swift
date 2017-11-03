//
//  CustomTableViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 02/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit

enum CellType {
    case custom
    case none
}

final class CustomTableViewCell: BasicTableViewCell {

    override func setupViews() {
        super.setupViews()

        addSubview(titleLabel)
        switch cellType {
        
        case .custom:
            addSubview(switchButton)
            
            switchButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 72, height: 44)
            switchButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
            
            
            titleLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: switchButton.rightAnchor, topPadding: 0, leftPadding: 20, bottomPadding: 0, rightPadding: 0, width: 0, height: 44)
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            titleLabel.textAlignment = .left
            
        case .none:
            titleLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, topPadding: 0, leftPadding: 20, bottomPadding: 0, rightPadding: 20, width: 0, height: 0)
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            titleLabel.textAlignment = .center
            
        }
    }
    
    
    private func setupTitle() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPadding: 0, leftPadding: 20, bottomPadding: 0, rightPadding: 6, width: 0, height: 0)
    }
    
    
    
    private func setupSwitchButton() {
        addSubview(switchButton)
        switchButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 44, width: 72, height: 0)
        switchButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
