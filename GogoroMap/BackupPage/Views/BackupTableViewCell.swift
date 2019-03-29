//
//  BackupTableViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 02/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit

final class BackupTableViewCell: UITableViewCell {
    
    enum CellType {
        case switchButton , none, backupButton
    }
    
    let cellType: CellType
    
    private func setupView() {
        addSubview(titleLabel)
        
        var titleHeight: CGFloat = 0
        var titleLeftAnchor: NSLayoutXAxisAnchor? = leftAnchor
        var titleRightAnchor: NSLayoutXAxisAnchor?
        var titletopAnchor: NSLayoutYAxisAnchor?

        switch cellType {
        case .switchButton:
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            setupRightView(with: switchButton)
            titleRightAnchor = switchButton.rightAnchor
            titleHeight = 44
            titleLabel.textAlignment = .left
            
        case .none:
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            titleLeftAnchor = nil
            
        case .backupButton:
            setupRightView(with: cloudImageView)
            addSubview(subtitleLabel)
            titletopAnchor = topAnchor
            titleLabel.font = .boldSystemFont(ofSize: 16)
            subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 5, rightPadding: 0, width: 0, height: 0)
        }
        
        
        titleLabel.anchor(top: titletopAnchor, left: titleLeftAnchor, bottom: nil, right: titleRightAnchor, topPadding: 0, leftPadding: 22, bottomPadding: 0, rightPadding: 0, width: 0, height: titleHeight)
    }
    
    private func setupRightView(with myView: UIView) {
        addSubview(myView)
        myView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 72, height: 44)
        myView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4).isActive = true
        
    }
    
    init(type: CellType = .none, title: String = "", subtitle: String = "" , titleColor: UIColor = .red) {
        cellType = type
        super.init(style: .default, reuseIdentifier: "")
        titleLabel.text = title
        titleLabel.textColor = titleColor
        subtitleLabel.text = subtitle
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let switchButton = UISwitch { $0.isOn = false }
    
    let titleLabel = UILabel {
        $0.font = .systemFont(ofSize: 18)
        $0.textAlignment = .center
    }
    
    let subtitleLabel = UILabel {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textAlignment = .left
    }
    
    let cloudImageView = UIImageView {
        $0.image = #imageLiteral(resourceName: "downloadFromCloud")
        $0.contentMode = .scaleAspectFit
    }
}
