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
        let storage = fetchData(from: .database).flatMap(decode)
            ?? (try! JSONDecoder().decode(Response.self, from: fetchData(from: .bundle)!).stations.map(BatteryStationPointAnnotation.init))
        processStation(storage)
    }
    
    private func processStation(_ storage: [BatteryStationPointAnnotation]) {
        DispatchQueue.global(qos: .default).async {
            let buildings = storage.filter(TabItemCase.building.hanlder)
            let operating = Set(storage).subtracting(buildings).sorted(by: <)
            let checkins = operating.filter(TabItemCase.checkin.hanlder)
            self.checkins = checkins
            self.buildings = buildings.sorted(by: <)
            self.operations = operating
            self.unchecks = Set(operating).subtracting(checkins).sorted(by: <)
        }
    }
    
    static let shared = DataManager()
    
    var originalStations: [BatteryStationPointAnnotation] { buildings + operations }
   
    @objc dynamic var lastUpdate: Date = Date()
    
    func save() {
        guard let data = try? JSONEncoder().encode(originalStations) else { return }
        UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
    }
  
    var stations: [BatteryStationPointAnnotation] {
        set { processStation(newValue) }
        get { operations }
    }
    
    var operations: [BatteryStationPointAnnotation] = []
    
    var checkins: [BatteryStationPointAnnotation] = []
    
    var unchecks: [BatteryStationPointAnnotation] = []
    
    var buildings: [BatteryStationPointAnnotation] = []
    
    func fetchStations(completionHandler: (([BatteryStationPointAnnotation]) -> [BatteryStationPointAnnotation])? = nil) {
        fetchData { (result) in
            guard case let .success(data) = result, let stations = (try? JSONDecoder().decode(Response.self, from: data))?.stations.map(BatteryStationPointAnnotation.init) else {
                return
            }
            let handler = completionHandler ?? DataManager.shared.originalStations.keepOldUpdate
            self.stations = handler(stations)
            self.lastUpdate = Date()
        }
    }
    
    private func decode(data: Data) -> [BatteryStationPointAnnotation]? {
        try? JSONDecoder().decode([BatteryStationPointAnnotation].self, from: data)
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
