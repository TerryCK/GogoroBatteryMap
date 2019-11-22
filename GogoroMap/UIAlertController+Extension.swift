//
//  UIAlertController+Extension.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/11/22.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit.UIAlertController

extension UIAlertController {
    static let locationAlertController: UIAlertController = {
        let alertController = UIAlertController(title: "定位權限已關閉",
                                                message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "確認", style: .default))
        return alertController
    }()
}

