//
//  DataGettable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation


typealias CompleteHandle = () -> Void

typealias Results<T: CustomPointAnnotation> = (reservesArray: [T], discardArray: [T])

protocol DataGettable: CloudBackupable {
    
    func initializeData()
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    
    func saveToDatabase(with annotations: [CustomPointAnnotation])
    
}



extension DataGettable where Self: MapViewController {    
    
    
    
    func initializeData() {
        
        let isFirstTimeLaunch = !UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) && annotations.isEmpty
        
            if isFirstTimeLaunch {
                
                annotations = getAnnotationFromFile()
                
            } else if mapView.annotations.isEmpty {
                
                annotations = getAnnotationFromDatabase()
           
        }
        
                getAnnotationFromRemote()
        
    }
   
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation] {
        guard
            let annotationsData = UserDefaults.standard.value(forKey: Keys.standard.annotationsKey) as? Data,
            let annotationFromDatabase =  annotationsData.toAnnoatations else {
                return getAnnotationFromFile()
        }
        print("get data from database")
        return annotationFromDatabase
    }
    
    
    
    
    private func getAnnotationFromFile() -> [CustomPointAnnotation] {
        guard
            let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
            let data = try? NSData(contentsOfFile: filePath) as Data,
            let annotationsFromFile = data.parsed else {
                return [CustomPointAnnotation]()
        }
        print("get data from local file")
        return annotationsFromFile
    }
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle? = nil) {
        
        guard let url = URL(string: Keys.standard.gogoroAPI) else { return }
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            defer {
                NetworkActivityIndicatorManager.shared.networkOperationFinished()
                if let completeHandle = completeHandle {
                    completeHandle()
                }
            }
            
            if let err = err {
                dataFromDatabase()
                print("Failed: ", err)
                return
            }
            
            guard let annotationFromRemote = data?.parsed,
                annotationFromRemote.count > 50 else {
                    dataFromDatabase()
                    return
            }
            
            print("get data from romote")
            
            (self.annotations, self.willRemovedAnnotations) = self.annotations.merge(from: annotationFromRemote)

            }.resume()
        
        func dataFromDatabase() {
            if self.annotations.isEmpty {
                self.annotations = self.getAnnotationFromDatabase()
            }
        }
    }

    func saveToDatabase(with annotations: [CustomPointAnnotation]) {
        let archiveData = annotations.toData
        UserDefaults.standard.set(archiveData, forKey: Keys.standard.annotationsKey)
        UserDefaults.standard.synchronize()
        post()
    }
    
    private func post() {
        NotificationCenter.default.post(name: NotificationName.shared.manuContent, object: nil)
    }
}


//MARK: Parsed Data using model of CustomPointAnnotation
extension Data {
    var toAnnoatations: [CustomPointAnnotation]? {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? [CustomPointAnnotation]
    }
}

// TODO:- Refactor for functional programming
// MARK : get unique element Dictionary and reserve origin elements data
extension Array where Element: CustomPointAnnotation {
    
    private func getDictionary(with array: Array) -> Dictionary<String, Element> {
        var dic = [String: Element]()
        
        let setElementToDictionary = { (element: Element) in
            dic[element.title ?? ""] = element
        }
        
        array.forEach(setElementToDictionary)
        forEach(setElementToDictionary)
        
        return dic
    }
    
    
    func merge(from remote: Array) -> Results<Element> {
        let reserveTable = remote.map { $0.title ?? "" }
        return getDictionary(with: remote).reduce(([Element](), [Element]())) { (result: Results, element) in
            return reserveTable.contains(element.key) ? (result.reservesArray + [element.value], result.discardArray) :
                (result.reservesArray, result.discardArray + [element.value])
        }
    }
    
    func areArrayEqual(otherArray: [Element]) -> Bool {
        guard count == otherArray.count else { return false }
        return zip(sorted { $0.title! > $1.title! }, otherArray.sorted { $0.title! > $1.title! }).enumerated().filter() {
            return $1.0 == $1.1
            }.count == count
    }
}

