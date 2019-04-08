//
//  SupplementaryCell.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/4/8.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit

final class SupplementaryCell: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(title: String? = nil, subtitle: String? = nil, titleTextAlignment: NSTextAlignment = .natural) {
        self.init()
        titleLabel.text = title
        subtitleLabel.text = subtitle
        titleLabel.textAlignment = titleTextAlignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    lazy var titleLabel = UILabel {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    lazy var subtitleLabel = UILabel {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.textColor = .lightGray
    }
    
    func setupView() {
        [titleLabel, subtitleLabel].forEach(addSubview)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 12, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 22)
        
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
}
