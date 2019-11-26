//
//  CloudBackupable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 01/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


extension CKAccountStatus: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .available:         return "iCloud is available"
        case .noAccount:         return "尚未登入"
        case .restricted:        return "iCloud設置受家長或文件的限制"
        case .couldNotDetermine, _: return "請稍後再嘗試"
        }
    }
}

extension Optional where Wrapped: Comparable {
    
    static func >(lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (left?, right?): return left > right
        default: return false
        }
    }
}


extension CKContainer {
    
    func fetchData(completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        privateCloudDatabase.perform(CKQuery(recordType: "BatteryStationPointAnnotation", predicate: NSPredicate(value: true)), inZoneWith: nil) { (records, error) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            DispatchQueue.main.async { completionHandler(records, error) }
        }
    }
    
    func save(data: Data, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
        let cloudRecord = CKRecord(recordType: "BatteryStationPointAnnotation")
        cloudRecord.setValue(data, forKey: "batteryStationPointAnnotation")
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        privateCloudDatabase.save(cloudRecord) { (record, error) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            DispatchQueue.main.async { completionHandler(record, error) }
        }
    }
    
    func fetchUserID(completionHanlder: @escaping (String) -> Void) {
        fetchUserID { (_, result) in
            DispatchQueue.main.async { completionHanlder(result ?? "iCloud 目前無法使用 請稍後嘗試") }
        }
    }
    
    private func fetchUserID(completionHanlder: @escaping (Error?, String?) -> Void) {
        requestApplicationPermission(.userDiscoverability) { status, error in
            guard error == nil else {
                completionHanlder(error, nil)
                return
            }
            guard status == .granted else {
                completionHanlder(nil, "歡迎回來")
                return
            }
            self.fetchUserRecordID { (recordId, error) in
                guard error == nil, let recordId = recordId else {
                    completionHanlder(error, nil)
                    return
                }
                
                if #available(iOS 10.0, *) {
                    self.discoverUserIdentity(withUserRecordID: recordId) { identity, error in
                        guard let components = identity?.nameComponents, error == nil else {
                            completionHanlder(error, nil)
                            print(error!)
                            return
                        }
                        completionHanlder(nil, "\(PersonNameComponentsFormatter().string(from: components))  歡迎回來")
                    }
                } 
            }
        }
    }
}
