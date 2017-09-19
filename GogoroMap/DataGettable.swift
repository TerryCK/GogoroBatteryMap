//
//  DataGettable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

typealias CompleteHandle = () -> Void

protocol DataGettable {
    
    func initializeData()
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    
    func parsed(with data: Data?) -> [CustomPointAnnotation]?
    
    func saveToDatabase(with annotations: [CustomPointAnnotation])
    
    func merge<T: CustomPointAnnotation>(to origin: [T], from new: [T]) -> (result: [T], discard: [T])
}



extension DataGettable where Self: MapViewController {
    
    func saveToDatabase(with annotations: [CustomPointAnnotation]) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: annotations), forKey: Keys.standard.annotationsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation] {
        guard
            let annotationsData = UserDefaults.standard.value(forKey: Keys.standard.annotationsKey) as? Data,
            let annotationFromDatabase = NSKeyedUnarchiver.unarchiveObject(with: annotationsData) as? [CustomPointAnnotation] else {
                return getAnnotationFromFile()
        }
        print("get data from database")
        return annotationFromDatabase
    }
    
    private func getAnnotationFromFile() -> [CustomPointAnnotation] {
        guard
            let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
            let data = try? NSData(contentsOfFile: filePath) as Data,
            let annotationsFromFile = parsed(with: data) else {
                return [CustomPointAnnotation]()
        }
        print("get data from local file")
        return annotationsFromFile
    }
    
    func parsed(with data: Data?) -> [CustomPointAnnotation]? {
        guard
            let data = data,
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else {
                return nil
        }
        
        let stations: [Station] =  jsonDic.map { (stationDic) in
            return Station(dictionary: stationDic)
        }
        
//        return getObjectArray(from: stations, userLocation: currentUserLocation)
        return stations.customPointAnnotations
    }
    
    func initializeData() {
        DispatchQueue.global().async {
            if !UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) && self.annotations.isEmpty {
                self.annotations = self.getAnnotationFromFile()
            }
            if self.mapView.annotations.isEmpty {
                self.annotations = self.getAnnotationFromDatabase()
            }
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
                dataFromDatabase()
                print("Failed: ", err)
                return
            }
            
            guard let annotationFromRemote = self.parsed(with: data),
                annotationFromRemote.count > 50 else {
                    dataFromDatabase()
                    return
            }
            print("get data from romote")
            DispatchQueue.main.async {
                (self.annotations, self.willRemovedAnnotations) = self.merge(to: self.annotations, from: annotationFromRemote)
            }
            
            }.resume()
        
        func dataFromDatabase() {
            if self.annotations.isEmpty {
                DispatchQueue.main.async {
                    self.annotations = self.getAnnotationFromDatabase()
                }
                
            }
        }
    }
    
    
    
    func merge<T: CustomPointAnnotation>(to origin: [T], from new: [T]) -> (result: [T], discard: [T]) {
        
        var dic = [String: T]()
        
        var result = [T]()
        var discard = [T]()
        let newElementsTitle = new.map { $0.title ?? "" }
        
        new.forEach { dic[$0.title ?? ""] = $0 }
        origin.forEach { dic[$0.title ?? ""] = $0 }
        
        for (key, value) in dic {
            
            if newElementsTitle.contains(key) {
                result.append(value)
            } else {
                discard.append(value)
            }
        }
        
        print("result: ", result.count , " discard:", discard.count)
        return (result: result, discard: discard)
    }
    
    
    func areArrayEqual<T: CustomPointAnnotation>(array: [T], otherArray: [T]) -> Bool {
        guard array.count == otherArray.count else { return false }
        
        return zip(array.sorted { $0.title! > $1.title! }, otherArray.sorted { $0.title! > $1.title! }).enumerated().filter() {
            return $1.0 == $1.1
            }.count == array.count
        
    }
}

extension DataGettable {
    
    func matchForAnnotationCorrect(annotationsCounter: Int, mapViewsAnnotationsCounter: Int) {
        // Mark: mapView remaind nil when annotations removed, so -1 to offset it.
        // Mark: check for avoid add annotation at same location which case too closeing to find
        
        let differential = Swift.abs(annotationsCounter - mapViewsAnnotationsCounter)
        if differential > 1 {
            let errorMessage = """
            error: annotation view count out of controller!!
            annotations:", \(annotationsCounter), " mapView:", \(mapViewsAnnotationsCounter)
            """
            print(errorMessage)
            
        } else {
            print(" ** annotation view count currect ** ")
        }
    }
}
