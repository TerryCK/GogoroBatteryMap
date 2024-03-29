//
//  DataManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Crashlytics

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
        guard let data = try? JSONEncoder().encode(self.originalStations) else { return }
        UserDefaults.standard.set(data, forKey: Keys.standard.annotationsKey)
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
        (try? JSONDecoder().decode(Gogoro.self, from: data))?.stations.map(BatteryStationPointAnnotation.init)
    }
            
    private func decode(data: Data) -> [BatteryStationPointAnnotation]? {
        try? JSONDecoder().decode([BatteryStationPointAnnotation].self, from: data)
    }
    
    var remoteStorage: [Gogoro.Station] = []
    
    func fetchStations(onCompletion: (() -> Void)? = nil) {
        UIApplication.mapViewController?.navigationItem.title = "資料更新中..."
        
        let handler: (Gogoro) -> Void = { payload in
            let stations = payload.stations
            self.remoteStorage = stations
            let result = stations.map(BatteryStationPointAnnotation.init)
            self.processStation(DataManager.shared.originalStations.keepOldUpdate(with: result),
                                completion: onCompletion)
        }
        
        queue.async {
            self.fetchData(api: .script) { result in
                guard case let .success(data) = result else { return }
                do {
                    handler(try JSONDecoder().decode(Gogoro.self, from: data))
                } catch {
                    print("\n *** encounter the parser error: \(error) *** \n")
                    self.fetchData(api: .gogoro) { result in
                        if case let .success(data) = result {
                            if let payload = try? JSONDecoder().decode(Gogoro.self, from: data) {
                                handler(payload)
                            }
                        }
                    }
                }
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
        case gogoro, goShare, script
        var url: URL? { URL(string: api) }
        var api: String {
            switch self {
            case .gogoro: return Keys.standard.gogoroAPI
            case .script: return GoogleAppScript(id: Keys.standard.scriptAPIKey).apiString
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
        AF.request(url).response { (response) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            switch response.data {
            case .some(let payload):  completionHandler(.success(payload))
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
