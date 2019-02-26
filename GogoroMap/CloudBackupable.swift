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


protocol CloudBackupable {
    
    var database: CKDatabase { get }
    
    var recordType: String { get }
    
    var recordKey: String { get }
    
    
    func backupToCloud(with data: Data, completed: @escaping () -> ())
    
    //    func recoverDataFromCloud(completed: @escaping CloudCompleteHandler)
    
    //    func backupToCloud(with annotations: [CustomPointAnnotation])
    //
    //    func getAnnoatationsFromCloud(completed: @escaping CloudCompleteHandler)
    
    //    func deleteAllBackup()
    //
    //    func getUserName()
    func query(completed: @escaping ([CKRecord]?, Error?) -> ())
    func updateUserStatus(completed: @escaping (CKAccountStatus, Error?) -> Void)
    
}







extension CloudBackupable {
    
    var container: CKContainer { return CKContainer.default() }
    
    var database:  CKDatabase  { return container.privateCloudDatabase }
    
    var recordType: String  { return "CustomPointAnnotations" }
    
    var recordKey: String   { return "customPointAnnotations" }
    
    typealias CompletedHandler = () -> ()
    
    func backupToCloud(with data: Data, completed: @escaping CompletedHandler) {
        print("saving data to cloud")
        
        let cloudRecord = CKRecord(recordType: recordType)
        let cloudObject = data as CKRecordValue
        cloudRecord.setObject(cloudObject, forKey: recordKey)
        
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        
        database.save(cloudRecord) { (record, error) in
            
            guard error == nil, record != nil else {
                print("cloud error: \(String(describing: error))")
                return
            }
            print("saved record to cloud")
            completed()
            
        }
    }
    
    
    //    func createdToCloud(with annotations: [CustomPointAnnotation]) {
    //        annotations.toData.backupToCloud()
    //    }
    
    
    //    func backupToCloud(with annotations: [CustomPointAnnotation]) {
    //
    //
    //        checkTheCloudFileExist {  (cloudStatus) in
    //
    //            switch cloudStatus {
    //            case .create:
    //                self.createdToCloud(with: annotations)
    //
    //            case .modify:
    //                self.modify(with: annotations)
    //            }
    //        }
    
    //    }
    
    
    
    func query(completed: @escaping ([CKRecord]?, Error?) -> ()) {
        let date = NSDate(timeInterval: -60.0 * 120 * 60, since: Date())
        let predicate = NSPredicate(format: "creationDate > %@", date)
        let query = CKQuery(recordType: recordType, predicate: predicate)
//        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil, completionHandler: completed)
    }
    
    func checkTheCloudFileExist() {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil, let records = records else {
                print("query error", error ?? "error")
                return
            }
            print(records)
            
        }
    }
    
    typealias CloudCompleteHandler = ([CustomPointAnnotation]) -> Void
    
    func recoverDataFromCloud(completed: @escaping CloudCompleteHandler) {
        
        print("quering")
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record: CKRecord?) in
//            NSKeyedUnarchiver.unarchiveObject(with: self) as? [CustomPointAnnotation]
            let data = record?.value(forKey: self.recordKey) as? Data
            if let annotations = data.map(NSKeyedUnarchiver.unarchiveObject) as? [CustomPointAnnotation] {
                completed(annotations)
            }
//            guard let rawData = record?.value(forKey: self.recordKey) as? Data,
//                let annoatations = rawData.toAnnoatations else { return }
//            completed(annoatations)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            let _ = error.map { print($0.localizedDescription)  }
            
            
            //TODO: - end todo
        }
        
        database.add(operation)
    }
    
    
    
    
    //    func modify(with annotations: [CustomPointAnnotation]) {
    //
    //        func modifyBlock(record : CKRecord?) -> Void {
    //            print("record")
    //            guard let record = record else {
    //                print("can't get record")
    //                return
    //            }
    //
    //            record[self.recordKey] = annotations.toData.toRecordValue
    //
    //            let records = [record]
    //            let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
    //
    //            modifyOperation.perRecordCompletionBlock = { (record, error) in
    //                if error == nil {
    //                    print("data succeed modified")
    //                } else {
    //                    print("data modified fallure: \(String(describing: error))")
    //                }
    //            }
    //
    //            self.database.add(modifyOperation)
    //        }
    //
    //
    //        print("modify Annoataions")
    //        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    //        let operation = CKQueryOperation(query: query)
    //        operation.recordFetchedBlock = modifyBlock
    //        operation.queryCompletionBlock = { (cursor, error) in
    //            guard error == nil else {
    //                print(error?.localizedDescription ?? "Error")
    //                return
    //            }
    //
    //            // 結束後要做什麼事情
    //        }
    //        database.add(operation)
    //    }
    
    
    
    
    
    //    // TODO: - Merge query Database and get annotatiaons
    //    func queryDatabase() {
    //        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    //        database.perform(query, inZoneWith: nil) { (records, _) in
    //            guard let records = records else { return }
    //            let sorted = records.sorted(by: { (record1, record2) -> Bool in
    //                record1.creationDate?.timeIntervalSince1970 ?? 0.0 > record2.creationDate?.timeIntervalSince1970 ?? 0.0
    //            })
    //            guard let lastedRecord = sorted.first else { return }
    //
    //            guard let annotationsData = lastedRecord as? Data,
    //                let annotations = NSKeyedUnarchiver.unarchiveObject(with: annotationsData) as? [CustomPointAnnotation] else {  return  }
    //
    //            let result: [CustomPointAnnotation] = annotations.flatMap {
    //                $0.value(forKey: self.recordType) as? CustomPointAnnotation  }
    //            print("annotations:", result)
    //        }
    //
    //    }
    
    //    func getAnnotationsFromCloud() -> [CustomPointAnnotation] {
    //        guard
    //            let annotationsData = UserDefaults.standard.value(forKey: recordType) as? Data,
    //            let annotationFromDatabase = NSKeyedUnarchiver.unarchiveObject(with: annotationsData) as? [CustomPointAnnotation] else {
    //                return getAnnotationFromFile()
    //        }
    //        print("get data from database")
    //        return annotationFromDatabase
    //    }
    
    func updateUserStatus(completed: @escaping (CKAccountStatus, Error?) -> Void) {
        container.accountStatus(completionHandler: completed)
    }
}


extension UILabel: CloudBackupable {} 

extension CloudBackupable where Self == UILabel {
    
    typealias UserIDHandler = (CKRecordID) -> Void
    
    private func fetchRecordID(completed: @escaping UserIDHandler) {
        container.fetchUserRecordID { (recordId, error) in
            guard error == nil, let recordId = recordId else {
                print("cloud user ID fetch error: \(error!)")
                return
            }
            
            completed(recordId)
        }
    }
    
    @available (iOS 10, *)
    private func getAndUpdataUserName(recordID: CKRecordID)-> Void {
        container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
            guard let components = identity?.nameComponents, error == nil else {
                print(error!)
                return
            }
            let fullName = PersonNameComponentsFormatter().string(from: components)
            DispatchQueue.main.async { self.text = "iCloud： \(fullName)" }
        }
    }
    
    private func requestPermission() {
        container.requestApplicationPermission(.userDiscoverability) { status, error in
            guard status == .granted, error == nil else {
                print(error!)
                return
            }
            
            if #available(iOS 10, *) {
                self.fetchRecordID(completed: self.getAndUpdataUserName)
            } else {
                self.text = "please upgrade to iOS 10"
            }
        }
    }
    
    
    func updateUserStatus(completed: @escaping (CKAccountStatus)->()) {
        
        container.accountStatus { (status, error) in
            let _ = error.map { self.text = " \($0)"}
            
            if status == .available {
                 self.requestPermission()
            }
            
            DispatchQueue.main.async {
                self.text = status.description
            }
            
            completed(status)
        }
    }
    
}
extension CloudBackupable where Self == BackupViewController {
    
    func queryingBackupData() {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        print("queryingBackupData")
        query { (records, error) in
            guard error == nil, let records = records else {
                print("cloud query error:", error!)
                return
            }
            
            self.backupDataHandler(with: records)

            
        }
    }
    
        func backupDataHandler(with records: [CKRecord]) {
            self.backupDatas = records.map {
                let creationData = $0.creationDate?.timeIntervalSince1970
                let data = $0.value(forKey: self.recordKey) as? Data
                return BackupData(timeInterval: creationData, data: data)
                }.sorted(by: { (data1, data2) -> Bool in
                    data1.timeInterval ?? 0.0 > data2.timeInterval ?? 0.0
                })
            
            DispatchQueue.main.async {
                self.backupfooterView.subtitleLabel.text = "最後備份時間: \(self.backupDatas.first?.timeInterval?.toTimeString ?? "")"
                NetworkActivityIndicatorManager.shared.networkOperationFinished()
            }
           
        }
    
}



// TODO: - check user login status of cloud accunt, Notifications for all of devices,
extension UserDefaults: CloudBackupable {
//    func saveDataToCloudFromDatabase() {
//        guard let data = value(forKey: Keys.standard.annotationsKey) as? Data
//            else { return }
//        data.backupToCloud()
//    }
    var databaseToData: Data? {
        return value(forKey: Keys.standard.annotationsKey) as? Data
    }
    
    func saveNowTime() {
        set(Date.now, forKey: Keys.standard.nowDateKey)
        UserDefaults.standard.synchronize()
    }
    func getLastBackupTime() -> String {
        return string(forKey: Keys.standard.nowDateKey) ?? ""
    }
}

extension CKAccountStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .available:
            return "iCloud is available"
        case .restricted:
            return "iCloud settings are restricted by parental controls or a configuration profile"
        case .noAccount:
            return "the user not logged in"
        case .couldNotDetermine:
            return "please try again"
        }
    }
}

extension Data: CloudBackupable {
    func backupToCloud(completeHandler: @escaping ()->()) {
        backupToCloud(with: self, completed: completeHandler)
    }

    var toRecordValue: CKRecordValue { return self as CKRecordValue }
    
    func updataNotifiy() {
        NotificationCenter.default.post(name: .dataUpdata, object: self)
    }

    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file
        
        return bcf.string(fromByteCount: Int64(count))
    }
}


