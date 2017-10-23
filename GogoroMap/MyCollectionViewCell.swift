//
//  TableViewCell.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import Foundation
import UIKit

protocol MyCollectionViewCellDelegate: class { }

final class MyCollectionViewCell: BaseCollectionViewCell {
    
   weak var delegate: MyCollectionViewCellDelegate?
    
     lazy var titleLabel: UILabel = { 
        let label = UILabel(frame: CGRect(x: 20, y: 50, width: self.frame.width, height: 16))
        label.text = NSLocalizedString("Total:", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
        }()
    
    override func setupViews() {
        super.setupViews()
        viewContainer.addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: viewContainer.leftAnchor, bottom: viewContainer.bottomAnchor, right: nil, topPadding: 0, leftPadding: 20, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        titleLabel.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
    }
    
}


