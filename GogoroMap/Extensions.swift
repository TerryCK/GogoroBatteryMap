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
        UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static var lightBlue  : UIColor { .rgb(red: 149, green: 204, blue: 244)  }
    static var lightGreen : UIColor { .rgb(red: 45, green: 149, blue: 64)    }
    static var heavyBlue  : UIColor { .rgb(red: 17, green: 154, blue: 237)   }
    static var grassGreen : UIColor { .rgb(red: 85 , green: 177, blue: 114)  }
    static var lightRed   : UIColor { .rgb(red: 218 , green: 52, blue: 53)   }   
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
    func string(dateformat: String, timeZone: TimeZone = .autoupdatingCurrent) -> String {
        return DateFormatter {
            $0.dateFormat = dateformat
            $0.timeZone = timeZone
            }.string(from: self)
    }
}


extension TimeInterval {
    static func travelTimeConvert(seconds: TimeInterval) -> (hours: Int, minutes: Int) {
        return (Int(seconds) / 3600 , Int(seconds) % 3600 / 60)
    }
}

extension Double {
    var km: Double { return Double(String(format:"%.1f", self / 1000)) ?? 0 }
    
    var toRadian: CGFloat { return CGFloat(self * (Double.pi/180)) }
    
    var format: Double { return Double(String(format:"%.2f", self)) ?? 0 }

    var percentage: String { return String(format: "%.1f", self * 100)  }
    
    var toTimeString: String {
        let timestampDate = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd   HH:mm:ss"
        return dateFormatter.string(from: timestampDate)
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

extension UIViewController {
    // MARK: - UIViewController containment
    func displayContentController(_ controller: UIViewController, inView view: UIView) {
        addChild(controller)
        controller.view.frame = view.bounds
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func removeContentController(_ controller: UIViewController?) {
        controller?.willMove(toParent: nil)
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
    }
}

extension MKMapView {
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}
