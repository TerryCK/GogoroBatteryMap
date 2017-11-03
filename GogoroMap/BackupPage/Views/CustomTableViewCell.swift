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
    case backupData
}

final class CustomTableViewCell: BasicTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    private func setupView() {
        addSubview(titleLabel)
        
        var titleHeight: CGFloat = 0
        var titleLeftAnchor: NSLayoutXAxisAnchor? = leftAnchor
        var titleRightAnchor: NSLayoutXAxisAnchor?
        var titletopAnchor: NSLayoutYAxisAnchor?
        
        
        switch cellType {
            
        case .custom:
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            setupRightView(with: switchButton)
            
            titleRightAnchor = switchButton.rightAnchor
            titleHeight = 44
            titleLabel.textAlignment = .left
            
        case .none:
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            titleLabel.textColor = titleColor
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            titleLeftAnchor = nil
            
        case .backupData:
            setupRightView(with: cloudImageView)
            addSubview(subtitleLabel)
            
            titletopAnchor = topAnchor
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 5, rightPadding: 0, width: 0, height: 0)
            
        }
        
        titleLabel.anchor(top: titletopAnchor, left: titleLeftAnchor, bottom: nil, right: titleRightAnchor, topPadding: 0, leftPadding: 22, bottomPadding: 0, rightPadding: 0, width: 0, height: titleHeight)
    }
    
    private func setupRightView(with myView: UIView) {
        addSubview(myView)
        myView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 72, height: 44)
        myView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
        
    }
    var titleColor: UIColor = .white
    
    init(type: CellType, title: String = "",subtitle: String = "", titleColor: UIColor = .red) {
        
        super.init(type: type)
        self.titleColor = titleColor
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        myLabel.textAlignment = .center
        return myLabel
    }()
    
    lazy var subtitleLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "cell subtitle"
        myLabel.font = UIFont.systemFont(ofSize: 13)
        myLabel.textAlignment = .left
        return myLabel
    }()
    
    lazy var cloudImageView: UIImageView = {
        let myImageView = UIImageView(image: #imageLiteral(resourceName: "downloadFromCloud"))
        myImageView.contentMode = .scaleAspectFit
        return myImageView
    }()
    
    
}
