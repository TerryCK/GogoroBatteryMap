//
//  DataManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case general
}

final class DataManager: NSObject {
    
    enum Approach { case bundle, database }
    
    private override init() { }
    
    static let shared = DataManager()
    
    lazy var stations: [BatteryStationPointAnnotation] = {
        return fetchData(from: .database).flatMap(dataBridge) ??
            (try! JSONDecoder().decode(Response.self, from: fetchData(from: .bundle)!).stations.map(BatteryStationPointAnnotation.init))
    }()
    
    
    @objc dynamic var lastUpdate: Date = Date()
    
    func save() {
        guard let data = try? JSONEncoder().encode(stations) else { return }
        UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
    }
    
    func fetchStations(completionHandler: @escaping (Result<[BatteryStationPointAnnotation], Error>) -> Void) {
        fetchData { (result) in
            if case let .success(data) = result, let response = (try? JSONDecoder().decode(Response.self, from: data))?.stations {
                self.lastUpdate = Date()
                self.stations.keepOldUpdate(with: response.map(BatteryStationPointAnnotation.init))
                completionHandler(.success(self.stations))
            } else {
                completionHandler(.failure(ServiceError.general))
            }
        }
    }
    
    private func dataBridge(data: Data) -> [BatteryStationPointAnnotation]? {
        return (try? JSONDecoder().decode([BatteryStationPointAnnotation].self, from: data))
            ?? (NSKeyedUnarchiver.unarchiveObject(with: data) as? [CustomPointAnnotation])?.map(BatteryStationPointAnnotation.init)
    }
    
    private func fetchData(from apporach: Approach) -> Data? {
        switch apporach {
        case .bundle:
            return Bundle.main.path(forResource: "gogoro", ofType: "json").flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
        case .database:
            return UserDefaults.standard.data(forKey: Keys.standard.annotationsKey)
        }
    }
    
    private func fetchData(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: Keys.standard.gogoroAPI) else {
            completionHandler(.failure(ServiceError.general))
            return
        }
        
        print("API: \(url)")
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            switch data {
            case .some(let response):  completionHandler(.success(response))
            case .none: completionHandler(.failure(ServiceError.general))
            }
            }.resume()
    }
}
