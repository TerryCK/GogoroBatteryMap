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
    
    class var grassGreen: UIColor {
        return UIColor.rgb(red: 85 , green: 177, blue: 114)
    }
    
    class var lightRed: UIColor {
        return UIColor.rgb(red: 218 , green: 52, blue: 53)
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

extension Date {
    static let today: String = {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateString = formatter.string(from: date)
        return dateString
    } ()
}


extension Double {
    var km: Double {
        return Double(String(format:"%.1f", self / 1000)) ?? 0
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


//        case "iPod5,1":                                 return "iPod Touch 5"
//        case "iPod7,1":                                 return "iPod Touch 6"
//        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
//        case "iPhone4,1":                               return "iPhone 4s"
//        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
//        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
//        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
//        case "iPhone7,2":                               return "iPhone 6"
//        case "iPhone7,1":                               return "iPhone 6 Plus"
//        case "iPhone8,1":                               return "iPhone 6s"
//        case "iPhone8,2":                               return "iPhone 6s Plus"
//        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
//        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
//        case "iPhone8,4":                               return "iPhone SE"
//        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
//        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
//        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
//        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
//        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
//        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
//        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
//        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
//        case "iPad6,11", "iPad6,12":                    return "iPad 5"
//        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
//        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
//        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
//        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
//        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
//        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
//        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
//        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
//        case "AppleTV5,3":                              return "Apple TV"
//        case "AppleTV6,2":                              return "Apple TV 4K"
//        case "AudioAccessory1,1":                       return "HomePod"
//        case "i386", "x86_64":                          return "Simulator"
//        default:                                        return identifier



