//
//  AnswerEntension.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 07/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import Foundation
import Crashlytics

extension Answers {
    
    struct Name: RawRepresentable, Equatable, Hashable {
        
        typealias RawValue = String
        
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(rawValue: String) {
            self.init(rawValue)
        }
        
        static func ==(lhs: Answers.Name, rhs: Answers.Name) -> Bool {
            return rhs.hashValue == lhs.hashValue
        }
        
        var rawValue: String
        var hashValue: Int { return self.rawValue.hashValue }
        
    }
}

extension Answers {
    class func log(event eventName: Name, customAttributes funcName: String? = nil) {
        Answers.logCustomEvent(withName: "\(eventName.rawValue)s", customAttributes: [eventName.rawValue: funcName ?? "" ])
    }
    class func log(view contentNameOrNil: String? = nil, contentType contentTypeOrNil: String? = nil ,contentId contentIdOrNil: String? = nil, customAttributes customAttributesOrNil: [String : Any]? = nil) {
        Answers.logContentView(withName: contentNameOrNil, contentType: contentTypeOrNil, contentId: contentIdOrNil, customAttributes: customAttributesOrNil)
    }
    
}

extension Answers.Name {
    
    static let mapButton = Answers.Name(rawValue:"MapButton")
    static let manuButton = Answers.Name(rawValue:"ManuButton")
    static let purchaseEvent = Answers.Name(rawValue: "PurchaseEvent")
}
