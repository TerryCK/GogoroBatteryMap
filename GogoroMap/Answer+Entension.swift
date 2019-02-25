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
    enum Name: String {
        case MapButtons, ManuButton, PurchaseEvents
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
