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
    
    private override init() {
        super.init()
        let storage = fetchData(from: .database).flatMap(decode) ?? DataManager.parse(data: fetchData(from: .bundle)!)!
        remoteStorage = storage
        processStation(storage)
    }
    enum ProcessStrategy {
        case all, allExceptBuilding
    }
    
    func sorting() { processStation(originalStations) }
    
    func resetStations() {
        processStation(remoteStorage, strategy: .allExceptBuilding)
    }
    
    private func processStation(_ stations: [BatteryStationPointAnnotation], strategy: ProcessStrategy = .all) {
        
        DispatchQueue(label: "com.GogoroMap.processQueue").async {
            let origin = stations.sorted(by: <)
            self.operations = origin.filter(TabItemCase.nearby.hanlder)
            self.checkins = self.operations.filter(TabItemCase.checkin.hanlder)
            self.unchecks = self.operations.filter(TabItemCase.uncheck.hanlder)
            
            if strategy == .all {
                self.buildings = origin.filter(TabItemCase.building.hanlder)
            }
            self.lastUpdate = Date()
        }
    }
    
    static let shared = DataManager()
    
    var originalStations: [BatteryStationPointAnnotation] { buildings + operations }
    
    private var remoteStorage: [BatteryStationPointAnnotation] = []
    
    @objc dynamic var lastUpdate: Date = Date()
    
    func save() {
        guard let data = try? JSONEncoder().encode(originalStations) else { return }
        UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
    }
    
    private var queueHandler: [() -> Void] = []
    
    func recoveryStations(from records: [BatteryStationRecord]) {
        self.processStation(self.remoteStorage.merge(from: records), strategy: .allExceptBuilding)
    }
    
    var operations: [BatteryStationPointAnnotation] = []
    
    var checkins: [BatteryStationPointAnnotation] = []
    
    var unchecks: [BatteryStationPointAnnotation] = []
    
    var buildings: [BatteryStationPointAnnotation] = []
    
    static func parse(data: Data) -> [BatteryStationPointAnnotation]? {
        (try? JSONDecoder().decode(Response.self, from: data))?.stations.map(BatteryStationPointAnnotation.init)
    }
    
    private func decode(data: Data) -> [BatteryStationPointAnnotation]? {
           try? JSONDecoder().decode([BatteryStationPointAnnotation].self, from: data)
       }
    
    func fetchStations(onCompletion: (() -> Void)? = nil) {
        fetchData { (result) in
            guard case let .success(data) = result, let stations = Self.parse(data: data) else {
                return
            }
            self.remoteStorage = stations
            let result = DataManager.shared.originalStations.keepOldUpdate(with: stations)
            self.processStation(result)
            onCompletion?()
        }
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
        var url: URL? { URL(string: api) }
        
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
    var url: URL {  URL(string: apiString)! }
    var apiString : String { return "https://script.google.com/macros/s/\(id)/exec" }
}
