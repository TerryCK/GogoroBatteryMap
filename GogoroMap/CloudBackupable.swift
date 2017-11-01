//
//  CloudBackupable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 01/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudBackupable {
    
     var database: CKDatabase { get }
    
     var recordType: String { get }
    
    func uploadDataToCloud(with annotations: [CustomPointAnnotation])
    
    func getAnnoatationsFromCloud(completed: @escaping CloudCompleteHandler)
    
}

enum CloudStatus {
    case create
    case modify
}

extension Collection where Element: CustomPointAnnotation, Self: CloudBackupable {
    func uploadToCloud(with annotations: [Element]) {
        uploadDataToCloud(with: annotations)
    }
}

// TODO: - check user login status of cloud accunt, Notifications for all of devices,

extension CloudBackupable {
    
    var database: CKDatabase { return CKContainer.default().privateCloudDatabase }
    
    var recordType: String  { return "CustomPointAnnotations" }
    
    var recordKey: String { return "customPointAnnotations" }
    
    typealias CloudHandler = (CloudStatus) -> Void
    
    
    func createdToCloud(with annotations: [CustomPointAnnotation]) {
        
        print("saving data to cloud")
        
        let cloudRecode = CKRecord(recordType: recordType)
        let cloudObject = annotations.toRecordValue
        cloudRecode.setObject(cloudObject, forKey: recordKey)
        
        database.save(cloudRecode) { (record, error) in
            guard error == nil, record != nil else {
                print("cloud error: \(String(describing: error))")
                return
            }
            print("saved record to cloud")
        }
    }
    
    
    
    func uploadDataToCloud(with annotations: [CustomPointAnnotation]) {
        
        
        checkTheCloudFileExist {  (cloudStatus) in
            
            switch cloudStatus {
            case .create:
                self.createdToCloud(with: annotations)
                
            case .modify:
                self.modify(with: annotations)
            }
        }
        
    }
    
    func checkTheCloudFileExist(completed: @escaping CloudHandler) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil, let records = records else {
                print("query error", error ?? "error")
                return
            }
            
            let cloudStatus: CloudStatus = records.isEmpty ? .create : .modify
            
            completed(cloudStatus)
        }
    }
    
    typealias CloudCompleteHandler = ([CustomPointAnnotation]) -> Void
    
    func getAnnoatationsFromCloud(completed: @escaping CloudCompleteHandler) {
        
        print("quering")
        
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record: CKRecord?) in
            
            guard let rawData = record?.value(forKey: self.recordKey) as? Data,
                let annoatations = rawData.toAnnoatations else { return }
            completed(annoatations)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error")
                return
            }
            
            //TODO: - end todo
        }
        
        database.add(operation)
    }
    
    func modify(with annotations: [CustomPointAnnotation]) {
        
        func modifyBlock(record : CKRecord?) -> Void {
            print("record")
            guard let record = record else {
                print("can't get record")
                return
            }
            
            record[self.recordKey] = annotations.toRecordValue
            
            let records = [record]
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            
            modifyOperation.perRecordCompletionBlock = { (record, error) in
                if error == nil {
                    print("data succeed modified")
                } else {
                    print("data modified fallure: \(String(describing: error))")
                }
            }
            
            self.database.add(modifyOperation)
        }
        
        
        print("modify Annoataions")
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = modifyBlock
        operation.queryCompletionBlock = { (cursor, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "Error")
                return
            }
            
            // 結束後要做什麼事情
        }
        
        // 執行
        database.add(operation)
    }
    
    
    
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
}



extension CKContainer {
    
    static func accuntStatus() {
        self.default().accountStatus { (status, error) in
            if let error = error { print("iCloud accunt error:",error) }
            switch status {
                
            case .available:
                print("iCloud account is logged in")
            case .restricted:
                
                print("iCloud settings are restricted by parental controls or a configuration profile")
            case .noAccount:
                
                print("the user not logged in")
            case .couldNotDetermine:
                
                print("please try again")
            }
        }
    }
}
