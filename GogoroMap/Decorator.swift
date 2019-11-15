//
//  Decorator.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation

protocol Decorator: AnyObject {
    
    init()
}

extension Decorator where Self: NSObject {
    
    init(_ configureHandler: (Self) -> Void) {
        self.init()
        configureHandler(self)
    }
}


extension NSObject: Decorator { }
