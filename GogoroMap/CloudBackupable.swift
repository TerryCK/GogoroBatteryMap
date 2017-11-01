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
    
//    var predicated: String { get }
    
//    func accuntStatus()
    
//    func savaToCloud(with annotations: [CustomPointAnnotation])
//
//    func archive(with annotations: [CustomPointAnnotation]) -> Data
//
//    func recoverFromCloud() -> [CustomPointAnnotation]
//
//    func unarchive(with data: Data) -> [CustomPointAnnotation]
    
}

extension CloudBackupable  {
   
     var database: CKDatabase { return CKContainer.default().privateCloudDatabase }
    
     var recordType: String  { return "CustomPointAnnotations" }
    
     var predicatedFormat: String { return "customPointAnnotations = %@" }
    
    var recordKey: String { return "customPointAnnotations" }
    
    //MARK: - add new record to cloud
    func upadteToCloud(with annoatations: [CustomPointAnnotation]) {
        var getTheRecordKey: String = ""
        
    }
    
    func saveToCloud(with annotations: [CustomPointAnnotation]) {
        print("saving data to cloud")
        let cloudRecode = CKRecord(recordType: recordType)
        let cloudObject = annotations.toRecordValue
        
        cloudRecode.setObject(cloudObject, forKey: recordKey)

        database.save(cloudRecode) { (record, error) in
            guard error == nil,  record != nil else {
                print("cloud error: \(String(describing: error))")
                return
            }
            
            print("saved record to cloud")
        }
    }
    
   
    
    func query(with keywords: String = "customPointAnnotations")  {

        print("quering")

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { (record: CKRecord?) in
            guard let record = record else { return }
            
            print(record.recordID.recordName)
            
            if let rawData = record.value(forKey: self.recordKey) as? Data
            {
                
                print(type(of: rawData), rawData.toAnnoatations?.count)
            }
            
            //TODO: -
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

        print("modify Annoataions")
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record : CKRecord?) in
            guard let record = record else { return }
            
            record[self.recordKey] = annotations.toRecordValue
            
            let records = [record]
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            
            modifyOperation.perRecordCompletionBlock = { (record, error) in
                if error == nil {
                    print("資料修改完成")
                } else {
                    print("資料修改失敗: \(String(describing: error))")
                }
            }
            
            self.database.add(modifyOperation)
        }
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
    
    
    
    // TODO: - Merge query Database and get annotatiaons
    func queryDatabase() {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, _) in
            guard let records = records else { return }
            let sorted = records.sorted(by: { (record1, record2) -> Bool in
                record1.creationDate?.timeIntervalSince1970 ?? 0.0 > record2.creationDate?.timeIntervalSince1970 ?? 0.0
            })
            guard let lastedRecord = sorted.first  else { return }
            
            guard let annotationsData = lastedRecord as? Data,
                let annotations = NSKeyedUnarchiver.unarchiveObject(with: annotationsData) as? [CustomPointAnnotation] else {  return  }
            
            let result: [CustomPointAnnotation] = annotations.flatMap {
                $0.value(forKey: self.recordType) as? CustomPointAnnotation  }
            print("annotations:", result)
        }
        
    }
    
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
            if let error = error {
                print("iCloud accunt error:",error)
            }
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
