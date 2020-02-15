//
//  DataManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation
import UIKit

enum ServiceError: Error {
    
    case general
}

final class DataManager: NSObject {
    
    enum Approach { case bundle, database }
    
    
    private let queue = DispatchQueue(label: "com.GogoroMap.processQueue")
    
    private override init() {
        super.init()
        let storage = self.fetchData(from: .database).flatMap(self.decode) ?? DataManager.parse(data: self.fetchData(from: .bundle)!)!
        self.operations = storage.filter(TabItemCase.nearby.hanlder)
        queue.async {
            self.buildings  = storage.filter(TabItemCase.building.hanlder)
            self.checkins   = storage.filter(TabItemCase.checkin.hanlder)
            self.unchecks   = storage.filter(TabItemCase.uncheck.hanlder)
        }
    }
    
    
    func sorting() {
        queue.async { self.processStation(self.originalStations) }
    }
    
    func resetStations(completion: (() -> Void)?) {
        queue.async {
            self.processStation(self.remoteStorage.map(BatteryStationPointAnnotation.init), completion: completion)
        }
    }
    
    private func processStation(_ stations: [BatteryStationPointAnnotation], completion: (() -> Void)? = nil) {
        self.queue.async {
            let origin = stations.sorted(by: <)
            self.operations = origin.filter(TabItemCase.nearby.hanlder)
            self.buildings  = origin.filter(TabItemCase.building.hanlder)
            self.checkins   = origin.filter(TabItemCase.checkin.hanlder)
            self.unchecks   = origin.filter(TabItemCase.uncheck.hanlder)
            self.lastUpdate = Date()
            DispatchQueue.main.async {
                 UIApplication.mapViewController?.resetTitle()
            }
           
            completion?()
        }
    }
    
    
    static let shared = DataManager()
    
    @objc dynamic var lastUpdate: Date = Date()
    
    func save() {
        queue.async {
            guard let data = try? JSONEncoder().encode(self.originalStations) else { return }
            UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
        }
    }
    
    func recoveryStations(from records: [BatteryStationRecord]) {
        queue.async {
            let result = self.remoteStorage.map(BatteryStationPointAnnotation.init).merge(from: records)
            self.processStation(result)
        }
    }
    
    var originalStations: [BatteryStationPointAnnotation] { buildings + operations }
    
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
    
    var remoteStorage: [Response.Station] = []
    
    func fetchStations(onCompletion: (() -> Void)? = nil) {
        UIApplication.mapViewController?.navigationItem.title = "資料更新中..."
        queue.async {
            self.fetchData { (result) in
                guard case let .success(data) = result, let stations = (try? JSONDecoder().decode(Response.self, from: data))?.stations else {
                    return
                }
                self.remoteStorage = stations
                let result = stations.map(BatteryStationPointAnnotation.init)
                self.processStation(DataManager.shared.originalStations.keepOldUpdate(with: result), completion: onCompletion)
            }
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
