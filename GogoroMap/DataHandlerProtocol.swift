//
//  DataHandlerProtocol.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

typealias Results<T> = (reservesArray: [T], discardArray: [T]) where T: CustomPointAnnotation

protocol DataHandlerProtocol: CloudBackupable {
    
    func initializeData()
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation]
    
    func getAnnotationFromRemote(_ completeHandle: (() -> Void)?)
    
    func saveToDatabase(with annotations: [CustomPointAnnotation])
    
}

enum Result<T> {
    case success(T)
    case fail(Error?)
}
//
//final class DataManager {
//    private static func fetchData(withURL url: URL = URL(string: Keys.standard.gogoroAPI)!, onCompletion handler: @escaping (Result<Data>) -> Void) {
//        NetworkActivityIndicatorManager.shared.networkOperationStarted()
//        print("*** API: \(url) ***")
//        URLSession.shared.dataTask(with: url) { (data, _, error) in
//            NetworkActivityIndicatorManager.shared.networkOperationFinished()
//            switch data {
//            case .some(let data): handler(.success(data))
//            case .none          : handler(.fail(error))
//            }
//        }.resume()
//    }
//    
//    private init() {
//        switch UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) {
//        case false:
//            data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "gogoro", ofType: "json")!))
//        }
//        
//        
//        
//    }
//    static let shared = DataManager()
//    var data: Data
//    
//}


extension DataHandlerProtocol where Self: MapViewController {
    
    func initializeData() {
        
        DispatchQueue.global().async {
            if !UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey),
                self.annotations.isEmpty {
                //                self.annotations = self.getAnnotationFromBundle()
            } else if self.mapView.annotations.isEmpty {
                self.annotations = self.getAnnotationFromDatabase()
            }
            self.getAnnotationFromRemote()
        }
        
    }
    
    
    func getAnnotationFromDatabase() -> [CustomPointAnnotation] {
        
        guard
            let annotationsData = UserDefaults.standard.data(forKey: Keys.standard.annotationsKey),
            let annotationFromDatabase =  annotationsData.toAnnoatations else {
                return [CustomPointAnnotation]()
                //                return getAnnotationFromBundle()
        }
        print("get data from database")
        return annotationFromDatabase
    }
    
    
    private func getAnnotationFromBundle() -> [ResponseStationProtocol] {
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "gogoro", ofType: "json")!))
        return (try! JSONDecoder().decode(Response.self, from: data)).stations
    }
    
    func getAnnotationFromRemote(_ completeHandle: (() -> Void)? = nil) {
        guard let url = URL(string: Keys.standard.gogoroAPI) else { return }
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        
        print("*** API: \(url) ***")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            defer {
                NetworkActivityIndicatorManager.shared.networkOperationFinished()
                completeHandle?()
            }
            
            if let error = error {
                dataFromDatabase()
                print("Failed: \(error)")
                return
            }
            
            guard let data = data,
                let response = try? JSONDecoder().decode(Response.self, from: data),
                response.stations.count > 50 else {
                    dataFromDatabase()
                    return
            }
            
            }.resume()
        
        func dataFromDatabase() {
            if self.annotations.isEmpty {
                self.annotations = self.getAnnotationFromDatabase()
            }
        }
    }
    
    func saveToDatabase(with annotations: [CustomPointAnnotation]) {
//        let archiveData = annotations.toData
//        UserDefaults.standard.set(archiveData, forKey: Keys.standard.annotationsKey)
        post()
    }
    
    private func post() {
        NotificationCenter.default.post(name: .manuContent, object: nil)
    }
}


//MARK: Parsed Data using model of CustomPointAnnotation
extension Data {
    var toAnnoatations: [CustomPointAnnotation]? {
        return [CustomPointAnnotation]()
        //        return NSKeyedUnarchiver.unarchiveObject(with: self) as? [CustomPointAnnotation]
    }
    
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file
        
        return bcf.string(fromByteCount: Int64(count))
    }
}

extension Array where Element: CustomPointAnnotation {
    
    private func getDictionary(with remoteArray: Array) -> Dictionary<String, Element> {
        var dic = [String: Element]()
        remoteArray.forEach { dic[$0.title ?? ""] = $0 }
        forEach {
            dic[$0.title ?? ""]?.checkinCounter = $0.checkinCounter
            dic[$0.title ?? ""]?.checkinDay = $0.checkinDay
        }
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

