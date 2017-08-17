//
//  Extensions.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    class var lightBlue: UIColor {
        return UIColor.rgb(red: 149, green: 204, blue: 244)
    }
    
    class var lightGreen: UIColor {
        return UIColor.rgb(red: 45, green: 149, blue: 64)
    }
    class var heavyBlue: UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
    
}


extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?, right:  NSLayoutXAxisAnchor?,
                topPadding: CGFloat, leftPadding: CGFloat,
                bottomPadding: CGFloat, rightPadding: CGFloat,
                width: CGFloat, height: CGFloat
        ) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: leftPadding).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -rightPadding).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        
    }
}




extension Double {
    var km: String {
        return String(format:"%.1f", self/1000) }
    
    var format: Double {
        return Double(String(format:"%.2f", self))!
    }
    var toRadian: CGFloat {
        get { return CGFloat(self * (Double.pi/180))
        }
    }
    
}


extension Bundle {
    static var id: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
}
