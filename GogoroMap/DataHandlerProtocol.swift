//
//  DataGettable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

//typealias Results<T> = (reservesArray: [T], discardArray: [T]) where T: CustomPointAnnotation

//protocol DataGettable: CloudBackupable {
//
//    func initializeData()
//
//    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
//
//    func getAnnotationFromRemote(_ completeHandle: (() -> Void)?)
//
//    func saveToDatabase(with annotations: [CustomPointAnnotation])
//
//}

final class DataManager {
    
    private let jsonDecoder = JSONDecoder()
    
    private init() {
        let data = DataManager.fetchData(from: .database) ?? DataManager.fetchData(from: .bundle)!
        batteryStationPointAnnotatios = (try? jsonDecoder.decode(Response.self, from: data))?.stations.map(BatteryStationPointAnnotation.init)
        DataManager.fetchData { (result) in
            if case let .success(data) = result {
                self.batteryStationPointAnnotatios = (try? self.jsonDecoder.decode(Response.self, from: data))?.stations.map(BatteryStationPointAnnotation.init)
            }
        }
    }
    
    static func saveToDatabase(with annotations: [BatteryStationPointAnnotation]) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: annotations), forKey: Keys.standard.annotationsKey)
        NotificationCenter.default.post(name: .manuContent, object: nil)
    }
    
    static func restoreFromDatabase() -> [BatteryStationPointAnnotation]? {
        guard let data = DataManager.fetchData(from: .database) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [BatteryStationPointAnnotation]
    }
    
    static let shared = DataManager()
    private(set) var batteryStationPointAnnotatios: [BatteryStationPointAnnotation]? {
        willSet {
            if let batteryStationPointAnnotatios = batteryStationPointAnnotatios, let newValue = newValue {
               self.batteryStationPointAnnotatios = batteryStationPointAnnotatios.merge(new: newValue)
            }             
        }
    }
    
    enum Approach {
        case bundle, database
    }
    
    static func fetchData(from apporach: Approach) -> Data? {
        switch apporach {
        case .bundle:
            return Bundle.main.path(forResource: "gogoro", ofType: "json").flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
        case .database:
            return UserDefaults.standard.data(forKey: Keys.standard.annotationsKey)
        }
    }
    
    
    static func fetchData(completionHandler: @escaping (Result<Data>) -> Void) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        guard let url = URL(string: Keys.standard.gogoroAPI) else {
            completionHandler(.fail(nil))
            return
        }
        
        print("API: \(url)")
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            switch data {
            case .some(let response):  completionHandler(.success(response))
            case .none: completionHandler(.fail(error))
            }
            }.resume()
    }
    
}


enum Result<T> {
    case success(T)
    case fail(Error?)
}

//
//extension DataGettable where Self: MapViewController {
//    func initializeData() {
//
//        DispatchQueue.global().async {
//            if !UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey),
//                self.annotations.isEmpty {
//                self.annotations = self.getAnnotationFromBundle()
//            } else if self.mapView.annotations.isEmpty {
//                self.annotations = self.getAnnotationFromDatabase()
//            }
//            self.getAnnotationFromRemote()
//        }
//
//    }
//
//
//    func getAnnotationFromDatabase() -> [CustomPointAnnotation] {
//        guard
//            let annotationsData = UserDefaults.standard.value(forKey: Keys.standard.annotationsKey) as? Data,
//            let annotationFromDatabase =  annotationsData.toAnnoatations else {
//                return getAnnotationFromBundle()
//        }
//        print("get data from database")
//        return annotationFromDatabase
//    }
//
//
//    private func getAnnotationFromBundle() -> [CustomPointAnnotation] {
//        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "gogoro", ofType: "json")!))
//        return (try! JSONDecoder().decode(Response.self, from: data)).stations.map(CustomPointAnnotation.init)
//    }
//
//    func getAnnotationFromRemote(_ completeHandle: (() -> Void)? = nil) {
//        DataManager.fetchData { result in
//            switch result {
//            case .fail(let error): dataFromDatabase()
//            case .success(let data):
//                guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
//                    dataFromDatabase()
//                    return }
//                (self.annotations, self.willRemovedAnnotations) = self.annotations.merge(from: response.stations.map(CustomPointAnnotation.init))
//            }
//        }
//        func dataFromDatabase() {
//            if self.annotations.isEmpty {
//                self.annotations = self.getAnnotationFromDatabase()
//            }
//        }
//    }
//
//    func saveToDatabase(with annotations: [CustomPointAnnotation]) {
////        let archiveData = annotations.toData
////        UserDefaults.standard.set(archiveData, forKey: Keys.standard.annotationsKey)
//        UserDefaults.standard.synchronize()
//        post()
//    }
//
//    private func post() {
//        NotificationCenter.default.post(name: .manuContent, object: nil)
//    }
//}


// MARK: Parsed Data using model of CustomPointAnnotation
//extension Data {
////    var toAnnoatations: [CustomPointAnnotation]? {
////        return NSKeyedUnarchiver.unarchiveObject(with: self) as? [CustomPointAnnotation]
////    }
//
//    
//}

//extension Array where Element: CustomPointAnnotation {
//    
//    private func getDictionary(with remoteArray: Array) -> Dictionary<String, Element> {
//        var dic = [String: Element]()
//        remoteArray.forEach { dic[$0.title ?? ""] = $0 }
//        forEach {
//            dic[$0.title ?? ""]?.checkinCounter = $0.checkinCounter
//            dic[$0.title ?? ""]?.checkinDay = $0.checkinDay
//        }
//        return dic
//    }
//    
//    
//    
//    
//    func merge(from remote: Array) -> Results<Element> {
//        let reserveTable = remote.map { $0.title ?? "" }
//        return getDictionary(with: remote).reduce(([Element](), [Element]())) { (result: Results, element) in
//            return reserveTable.contains(element.key) ? (result.reservesArray + [element.value], result.discardArray) :
//                (result.reservesArray, result.discardArray + [element.value])
//        }
//    }
//}
//
