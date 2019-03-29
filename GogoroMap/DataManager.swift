//
//  DataManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation

protocol DataManagerProtocol {
    func saveToDatabase(with annotations: [BatteryStationPointAnnotation])
    var initialStations: [BatteryStationPointAnnotation] { get }
    func fetchStations(completionHandler: @escaping (Result<[BatteryStationPointAnnotation]>) -> Void)
}

final class DataManager {
    static let key: String = "batteryStationPointAnnotation"
    
    enum Approach { case bundle, database }
    
    private init() { }
    
    static let shared = DataManager()
    
    func saveToDatabase(with annotations: [BatteryStationPointAnnotation]) {
        guard let data = try? JSONEncoder().encode(annotations) else { return }
        UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
    }
    
    func dataBridge(data: Data) -> [BatteryStationPointAnnotation]? {
        return (try? JSONDecoder().decode([BatteryStationPointAnnotation].self, from: data))
            ?? (NSKeyedUnarchiver.unarchiveObject(with: data) as? [CustomPointAnnotation])?.map(BatteryStationPointAnnotation.init)
    }
    
    var initialStations: [BatteryStationPointAnnotation] {
        return fetchData(from: .database).flatMap(dataBridge) ?? fetchData(from: .bundle).flatMap {
            try? JSONDecoder().decode(Response.self, from: $0).stations.map(BatteryStationPointAnnotation.init)
        }!
    }
    
    func fetchStations(completionHandler: @escaping (Result<[BatteryStationPointAnnotation]>) -> Void) {
        fetchData { (result) in
            if case let .success(data) = result, let stations = (try? JSONDecoder().decode(Response.self, from: data))?.stations.map(BatteryStationPointAnnotation.init) {
                completionHandler(.success(stations))
            } else {
                completionHandler(.fail(nil))
            }
        }
    }
    
     func fetchData(from apporach: Approach) -> Data? {
        switch apporach {
        case .bundle:
            return Bundle.main.path(forResource: "gogoro", ofType: "json").flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
        case .database:
            return UserDefaults.standard.data(forKey: Keys.standard.annotationsKey)
        }
    }
    
    private func fetchData(completionHandler: @escaping (Result<Data>) -> Void) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        guard let url = URL(string: "https://wapi.gogoro.com/tw/api/vm/list") else {
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
