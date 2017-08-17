//
//  GuidePageViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit

final class GuidePageViewController: UIViewController {

    weak var mapViewController: MapViewController?
    
    private lazy var guideImageView: UIImageView! = { [unowned self] in
        let imageView: UIImageView = UIImageView(frame: self.view.frame)
        imageView.image = #imageLiteral(resourceName: "guidePage")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var okButton: UIButton = {
        let button = CustomButton(type: .system)
        button.setTitle("我知道了，按此繼續", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(guideImageView)
        guideImageView.addSubview(okButton)
        okButton.anchor(top: nil, left: guideImageView.leftAnchor, bottom: guideImageView.bottomAnchor, right: guideImageView.rightAnchor, topPadding: 0, leftPadding: 10, bottomPadding: 20, rightPadding: 10, width: 0, height: 35)
        okButton.centerXAnchor.constraint(equalTo: guideImageView.centerXAnchor).isActive = true
        
    }
    
    deinit {
        print("guide page controller deinitialize")
    }
    
    func dismissController () {
        UserDefaults.standard.set(true, forKey: "hasReviewedGuidePage")
        mapViewController?.setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        mapViewController?.getDataOffline()
        dismiss(animated: true, completion: nil)
    }
}
