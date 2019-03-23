//
//  Extensions.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import StoreKit
import Foundation
import MapKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static var lightBlue: UIColor {
        return .rgb(red: 149, green: 204, blue: 244)
    }
    
    static var lightGreen: UIColor {
        return .rgb(red: 45, green: 149, blue: 64)
    }
    
    static var heavyBlue: UIColor {
        return .rgb(red: 17, green: 154, blue: 237)
    }
    
    static var grassGreen: UIColor {
        return .rgb(red: 85 , green: 177, blue: 114)
    }
    
    static var lightRed: UIColor {
        return .rgb(red: 218 , green: 52, blue: 53)
    }
    
}



extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil, right:  NSLayoutXAxisAnchor? = nil,
                topPadding: CGFloat = 0, leftPadding: CGFloat = 0,
                bottomPadding: CGFloat = 0, rightPadding: CGFloat = 0,
                width: CGFloat = 0, height: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftPadding).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -rightPadding).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
// MARK: - Animation of infinity rotate 360˚
extension UIView {
    
    func rotate360Degrees(duration: CFTimeInterval = 1.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        layer.add(rotateAnimation, forKey: nil)
    }
    
    func stopRotating() {
        layer.sublayers?.removeAll()
    }
    
    func opacityAnimation(duration: CFTimeInterval = 0.75, hidden: Bool) {
        let hiddenAnimation = CABasicAnimation(keyPath: "opacity")
        hiddenAnimation.fromValue = hidden ? 0 : 1
        hiddenAnimation.toValue = hidden ? 1 : 0
        hiddenAnimation.duration = duration
        layer.add(hiddenAnimation, forKey: nil)
        isHidden = hidden
    }
    
    func willHidden(duration: CFTimeInterval = 0.75) {
        opacityAnimation(duration: duration, hidden: true)
    }
    
    func willDisplay(duration: CFTimeInterval = 0.75) {
        opacityAnimation(duration: duration, hidden: false)
    }
}


extension Date {
   
    static private func getTime(with formatterString: String) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = formatterString
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static var today: String  { return getTime(with: "yyyy.MM.dd") }
    
    static var now: String { return getTime(with: "yyyy.MM.dd HH:mm:ss") }
  
}


extension Double {
    var km: Double {
        return Double(String(format:"%.1f", self / 1000)) ?? 0
    }
    var toRadian: CGFloat {
        get { return CGFloat(self * (Double.pi/180))
        }
    }
    var format: Double {
        return Double(String(format:"%.2f", self)) ?? 0
    }

    var percentage: String {
        return String(format: "%.1f", self * 100)
    }
    var convertToHMS: String {
        
        let minutes = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let hours = Int(self / 3600)
        
        var result: String = ""
        
        result += hours > 0 ? "\(hours) 小時 " : ""
        result += "\(minutes + 1) 分鐘 "
        return result
    }
    
    var toTimeString: String {
        let timestampDate = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd   HH:mm:ss"
        return dateFormatter.string(from: timestampDate)
    }

}


extension Bundle {
    static var id: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
}




extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? "\(price)"
    }
}


enum DeviceMode: String {
    case iPhoneX
    case others
}

extension UIDevice {
    static var isiPhoneX: Bool {
        let heightOfiPhoneX: CGFloat = 812
        return modelName == .iPhoneX || UIScreen.main.bounds.height == heightOfiPhoneX
    }
    
    static var modelName: DeviceMode {
       
        var systemIfo = utsname()
        uname(&systemIfo)
        let machineMirror = Mirror(reflecting: systemIfo.machine)
        
        let identifier = machineMirror.children.reduce("") { (identifier, element)  in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        
        switch identifier {
        case "iPhone10,3", "iPhone10,6": return .iPhoneX
        default: return .others
        }
    }
}

extension MKMapPoint {
    var centerOfScreen: MKMapPoint {
        let factorOfPixelToMapPoint = 12000.0 / 320
        let offsetCenterX  = Double(UIScreen.main.bounds.width / 2) * factorOfPixelToMapPoint
        let offsetCenterY  = Double(UIScreen.main.bounds.height / 2) * factorOfPixelToMapPoint
        return MKMapPoint(x: x - offsetCenterX, y: y - offsetCenterY)
    }
}

extension UserDefaults {
    static var hasBuyItems: Bool { return standard.bool(forKey: Keys.standard.hasPurchesdKey) }
}
