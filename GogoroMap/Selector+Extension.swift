//
//  Selector+Extension.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 22/09/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import Foundation

// MARK: - MapViewController

extension Selector {
    static let checkin = {
        #selector(MapViewController.checkin)
    }
    static let unCheckin = {
        #selector(MapViewController.unCheckin)
    }
    static let navigating = {
        #selector(MapViewController.navigating)
    }
    
}




// MARK: - ManuViewController
extension Selector {
    
    static let performGuidePage = {
        #selector(MenuController.performGuidePage)
    }
    
    static let presentMail = {
         #selector(MenuController.presentMail)
    }
    
    static let recommand = {
        #selector(MenuController.recommand)
    }
    
    static let shareThisApp = {
        #selector(MenuController.shareThisApp)
    }
    
    static let moreApp = {
        #selector(MenuController.moreApp)
    }
    
    static let attempUpdate = {
        #selector(MenuController.attempUpdate)
    }
    static let restorePurchase = {
        #selector(MenuController.restorePurchase)
    }
}
 


