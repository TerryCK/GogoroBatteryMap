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

protocol DataGettable {
    
    func initializeData()
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
    
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    
    func saveToDatabase(with annotations: [CustomPointAnnotation])
    
}


extension DataGettable where Self: MapViewController {    
    func initializeData() {
        DispatchQueue.global().async {
            if !UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) && self.annotations.isEmpty {
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
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: annotations), forKey: Keys.standard.annotationsKey)
        UserDefaults.standard.synchronize()
        post()
    }
    
    
    private func post() {
        NotificationCenter.default.post(name: NotificationName.shared.manuContent, object: nil)
    }
}

extension Data {
    //MARK: Parsed Data using model of CustomPointAnnotation
    var parsed: [CustomPointAnnotation]? {
        guard
            let jsonDictionary = try? JSONSerialization.jsonObject(with: self) as? [String: Any],
            let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else {
                return nil
        }
        return jsonDic.map { Station(dictionary: $0) }.customPointAnnotations
    }
}


/*
 
extension DataGettable {
    //MARK: Check if number of annotation Views not correct.
    
    func matchForAnnotationCorrect(annotationsCounter: Int, mapViewsAnnotationsCounter: Int) {
        // Mark: mapView remaind nil when annotations removed, so -1 to offset it.
        // Mark: check for avoid add annotation at same location which case too closeing to find
        
        let differential = Swift.abs(annotationsCounter - mapViewsAnnotationsCounter)
        if differential > 1 {
            let errorMessage = """
            error: annotation view count out of control!!
            annotations:", \(annotationsCounter), " mapView:", \(mapViewsAnnotationsCounter)
            """
            print(errorMessage)
            
        } else {
            print(" ** annotation view count currect ** ")
        }
    }
}
 */

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
