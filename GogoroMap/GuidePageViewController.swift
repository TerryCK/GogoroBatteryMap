//
//  GuidePageViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Crashlytics

protocol GuidePageViewControllerDelegate: AnyObject {
    func setCurrentLocation(latDelta: Double, longDelta: Double)
}

final class GuidePageViewController: UIViewController {

    weak var delegate: GuidePageViewControllerDelegate?
    
    private lazy var guideImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: view.frame)
        imageView.image = #imageLiteral(resourceName: "guidePage")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var okButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle(NSLocalizedString("Press here and continue", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button                   
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.log(view: "Guide Page")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(guideImageView)
        guideImageView.addSubview(okButton)
        okButton.anchor(top: nil, left: guideImageView.leftAnchor, bottom: guideImageView.bottomAnchor, right: guideImageView.rightAnchor, topPadding: 0, leftPadding: 10, bottomPadding: 20, rightPadding: 10, width: 0, height: 35)
        okButton.centerXAnchor.constraint(equalTo: guideImageView.centerXAnchor).isActive = true
    }

    
    @objc func dismissController() {
        UserDefaults.standard.set(true, forKey: Keys.standard.beenHereKey)
        delegate?.setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        dismiss(animated: true, completion: nil)
    }
}
