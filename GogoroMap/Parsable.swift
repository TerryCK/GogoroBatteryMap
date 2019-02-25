//
//  Parsable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 01/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//
//
//import Foundation
//
//protocol Parsable {
//    var parsed: [CustomPointAnnotation]? { get }
//}
//
//extension Parsable {
//    var parsed: [CustomPointAnnotation]? {
//        let data: Data = self as? Data ?? Data()
//        guard
//            let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//            let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else {
//                return nil
//        }
//        return jsonDic.map(Station.init(dictionary:)).customPointAnnotations
//    }
//}
//
//extension Data: Parsable { }
//extension NSData: Parsable { }
//
