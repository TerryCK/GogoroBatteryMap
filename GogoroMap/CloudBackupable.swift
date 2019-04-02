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
        case .couldNotDetermine: return "請稍後再嘗試"
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


//extension CloudBackupable {
//
//    var container: CKContainer { return CKContainer.default() }
//
//    var database:  CKDatabase  { return container.privateCloudDatabase }
//
//    var recordType: String  { return String(describing: type(of: self)) }
//
//    func backupToCloud(with data: Data, completed: @escaping ()-> Void) {
//        print("saving data to cloud")
//
//        let cloudRecord = CKRecord(recordType: recordType)
//        let cloudObject = data as CKRecordValue
//        cloudRecord.setObject(cloudObject, forKey: recordType)
//
//        NetworkActivityIndicatorManager.shared.networkOperationStarted()
//
//        database.save(cloudRecord) { (record, error) in
//            NetworkActivityIndicatorManager.shared.networkOperationFinished()
//            guard error == nil, record != nil else {
//                print("cloud error: \(String(describing: error!))")
//                return
//            }
//            completed()
//
//        }
//    }
//
//
//
//    func query(completed: @escaping ([CKRecord]?, Error?) -> ()) {
//        let date = NSDate(timeInterval: -60.0 * 120 * 60, since: Date())
//        let predicate = NSPredicate(format: "creationDate > %@", date)
//        let query = CKQuery(recordType: recordType, predicate: predicate)
////        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
//        database.perform(query, inZoneWith: nil, completionHandler: completed)
//    }
//
//    func checkTheCloudFileExist() {
//        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
//        database.perform(query, inZoneWith: nil) { (records, error) in
//            guard error == nil, let records = records else {
//                print("query error", error ?? "error")
//                return
//            }
//            print(records)
//
//        }
//    }
//
//    typealias CloudCompleteHandler = ([CustomPointAnnotation]) -> Void
//
//    func recoverDataFromCloud(completed: @escaping CloudCompleteHandler) {
//
//        print("quering")
//
//        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
//
//        let operation = CKQueryOperation(query: query)
//
//        operation.recordFetchedBlock = { (record: CKRecord?) in
////            NSKeyedUnarchiver.unarchiveObject(with: self) as? [CustomPointAnnotation]
//            let data = record?.value(forKey: self.recordType) as? Data
//            if let annotations = data.map(NSKeyedUnarchiver.unarchiveObject) as? [CustomPointAnnotation] {
//                completed(annotations)
//            }
////            guard let rawData = record?.value(forKey: self.recordKey) as? Data,
////                let annoatations = rawData.toAnnoatations else { return }
////            completed(annoatations)
//        }
//
//        operation.queryCompletionBlock = { (cursor, error) in
//            let _ = error.map { print($0.localizedDescription)  }
//
//
//            //TODO: - end todo
//        }
//
//        database.add(operation)
//    }
//}
