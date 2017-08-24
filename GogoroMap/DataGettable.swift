//
//  DataGettable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

protocol DataGettable {
    // from local file @app first launch start point
    func initializeData()
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    
    func parsed(with data: Data?) -> [CustomPointAnnotation]?
    
    func saveToDatabase(with annotations: [CustomPointAnnotation])
    
    func merge<T: CustomPointAnnotation>(to origin: [T], from new: [T]) -> (result: [T], discard: [T])
}

typealias CompleteHandle = () -> Void

extension DataGettable where Self: MapViewController {
    
    func saveToDatabase(with annotations: [CustomPointAnnotation]) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: annotations), forKey: Keys.standard.annotationsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation] {
        guard
            let annotationsData = UserDefaults.standard.value(forKey: Keys.standard.annotationsKey) as? Data,
            let annotationFromDatabase = NSKeyedUnarchiver.unarchiveObject(with: annotationsData) as? [CustomPointAnnotation] else {
                
                print("could not unachive from placeData")
                return getAnnotationFromFile()
        }
        return annotationFromDatabase
    }
    
   private func getAnnotationFromFile() -> [CustomPointAnnotation] {
        guard
            let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
            let data = try? NSData(contentsOfFile: filePath) as Data,
            let annotationsFromFile = parsed(with: data) else {
                return [CustomPointAnnotation]()
        }
        return annotationsFromFile
    }
    
    func parsed(with data: Data?) -> [CustomPointAnnotation]? {
        if
            let data = data,
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let jsonDic = jsonDictionary?["data"] as? [[String: Any]] {
            let stations =  jsonDic.map { Station(dictionary: $0) }
            return getObjectArray(from: stations, userLocation: currentUserLocation)
        }
        return nil
    }
    
    func initializeData() {
        guard UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) else {
            self.annotations = getAnnotationFromFile()
            return
        }
        DispatchQueue.global().async {
            self.annotations = self.getAnnotationFromDatabase()
            self.getAnnotationFromRemote()
            
        }
        
    }
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle? = nil) {
        
        guard let url = URL(string: Keys.standard.gogoroAPI) else { return }
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        
        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, err) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            
            defer {
                if let completeHandle = completeHandle {
                    completeHandle()
                }
            }
            
            if let err = err {
                self.annotations = self.getAnnotationFromDatabase()
                print("Failed: ", err)
                return
            }
            
            guard let annotationFromRemote = self.parsed(with: data),
                annotationFromRemote.count > 50 else {
                self.annotations = self.getAnnotationFromDatabase()
                return
            }
            self.annotations = self.merge(to: self.annotations, from: annotationFromRemote).result
            }.resume()
    }
    
    
    
    func merge<T: CustomPointAnnotation>(to origin: [T], from new: [T]) -> (result: [T], discard: [T]) {
        
        var dic = [String: T]()
        var result = [T]()
        var discard = [T]()
        let newElements = new.map { $0.title ?? "" }
        
        new.forEach { dic[$0.title ?? ""] = $0 }
        origin.forEach { dic[$0.title ?? ""] = $0 }
        
        
        for (key, value) in dic {
            if newElements.contains(key) {
                result.append(value)
            } else {
                discard.append(value)
            }
        }
        print("result.count", result.count)
        
        return (result: result, discard: discard)
    }
    
    
    
    func areArrayEqual<T: CustomPointAnnotation>(array: [T], otherArray: [T]) -> Bool {
        guard array.count == otherArray.count else { return false }
        
        return zip(array.sorted { $0.title! > $1.title! }, otherArray.sorted { $0.title! > $1.title! }).enumerated().filter() {
            return $1.0 == $1.1
            }.count == array.count
    }
    
    
}
