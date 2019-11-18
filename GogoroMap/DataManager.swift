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
    
    lazy var originalStations: [BatteryStationPointAnnotation] = {
        return fetchData(from: .database).flatMap(dataBridge) ??
            (try! JSONDecoder().decode(Response.self, from: fetchData(from: .bundle)!).stations.map(BatteryStationPointAnnotation.init))
    }()
   
    
    @objc dynamic var lastUpdate: Date = Date()
    
    func save() {
        guard let data = try? JSONEncoder().encode(stations) else { return }
        UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
    }
  
    var stations: [BatteryStationPointAnnotation] {
        set {
            buildings = newValue.filter(SegmentStatus.building.hanlder)
            originalStations = newValue
        }
        get { originalStations }
    }
    
    lazy var checkins: [BatteryStationPointAnnotation] = {
        originalStations.filter(SegmentStatus.checkin.hanlder)
    }()
    
    lazy var unchecks: [BatteryStationPointAnnotation] = {
        originalStations.filter(SegmentStatus.uncheck.hanlder)
    }()
    
    lazy var buildings: [BatteryStationPointAnnotation] = {
        originalStations.filter(SegmentStatus.building.hanlder)
    }()
    
    func fetchStations(completionHandler: (([BatteryStationPointAnnotation]) -> [BatteryStationPointAnnotation])? = nil) {
        fetchData { (result) in
            guard case let .success(data) = result, let stations = (try? JSONDecoder().decode(Response.self, from: data))?.stations.map(BatteryStationPointAnnotation.init) else {
                return
            }
            let handler = completionHandler ?? DataManager.shared.stations.keepOldUpdate
            self.stations = handler(stations)
            self.lastUpdate = Date()
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
    
    enum API {
        
        case gogoro, goShare
        var url: URL? { return URL(string: api) }
        
        var api: String {
            switch self {
            case .gogoro: return Keys.standard.gogoroAPI
            case .goShare: return GoogleAppScript(id: Keys.standard.goShareScriptID).apiString
            }
        }
    }
    
    
    private func fetchData(api: API = .gogoro, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = api.url else {
            completionHandler(.failure(ServiceError.general))
            return
        }
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

struct GoogleAppScript {
    
    let id: String
    var url: URL { return URL(string: apiString)! }
    var apiString : String { return "https://script.google.com/macros/s/\(id)/exec" }
}
