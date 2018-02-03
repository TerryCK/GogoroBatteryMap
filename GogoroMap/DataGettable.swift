//
//  DataGettable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation


typealias CompleteHandle = () -> Void

typealias Results<T> = (reservesArray: [T], discardArray: [T]) where T: CustomPointAnnotation

protocol DataGettable: CloudBackupable {
    
    func initializeData()
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    
    func saveToDatabase(with annotations: [CustomPointAnnotation])
    
}



extension DataGettable where Self: MapViewController {
    func initializeData() {

        DispatchQueue.global().async {
            if !UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey),
                self.annotations.isEmpty {
                self.annotations = self.getAnnotationFromFile()
            } else if self.mapView.annotations.isEmpty {
                self.annotations = self.getAnnotationFromDatabase()
            }
            self.getAnnotationFromRemote()
        }
        
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
                completeHandle.map {
                    $0()
                }
            }
            
            err.map {
                dataFromDatabase()
                print("Failed: ", $0)
                return
            }
            
            
            guard let annotationFromRemote = data?.parsed,
                annotationFromRemote.count > 50 else {
                    dataFromDatabase()
                    return
            }
            
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
        NotificationCenter.default.post(name: .manuContent, object: nil)
    }
}


//MARK: Parsed Data using model of CustomPointAnnotation
extension Data {
    
    var parsed: [CustomPointAnnotation]? {
        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: self) as? [[String: Any]], let jsonDic = jsonDictionary else {
                return nil
        }
        
        return jsonDic.map(Station.init).customPointAnnotations
     

    }
}

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
}

