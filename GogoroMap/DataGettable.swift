//
//  DataGettable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/18.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

protocol DataGettable {
    func saveParsed(with data: Data?)
    func getLocalData()
    func getData(_ completeHandle: CompleteHandle?) 
}

typealias CompleteHandle = () -> Void

extension DataGettable where Self: MapViewController {
    
    func saveParsed(with data: Data?) {
        
        saveToDatabase(with: data)
        
        guard
            let data = data,
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else { return }
        
        let stations = jsonDic.map { Station(dictionary: $0) }
        annotations = getObjectArray(from: stations, userLocation: currentUserLocation)
        var stationsOfAvailable = 0
        stations.forEach { stationsOfAvailable += $0.state == 1 ? 1 : 0 }
        stationData = (totle: stations.count, available: stationsOfAvailable)
    }
    
    
    private func saveToDatabase(with data: Data?) {
        UserDefaults.standard.set(data, forKey: Keys.standard.dataKey)
        UserDefaults.standard.synchronize()
    }
    
    func getLocalData() {
        
        var data: Data?
        if let dataFromDataBase = UserDefaults.standard.data(forKey: Keys.standard.dataKey) {
            data = dataFromDataBase
            
        } else if
            let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
            let dataFromFile = NSData(contentsOfFile: filePath) as Data? {
            
            data = dataFromFile
        }
        
        saveParsed(with: data)
    }
   
    
    func getData(_ completeHandle: CompleteHandle? = nil) {
        getLocalData()
        guard let url = URL(string: Keys.standard.gogoroAPI) else { return }
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            if let err = err {
                self.getLocalData()
                print("Failed: ", err)
                return
            }
            
            self.saveParsed(with: data)
            
            if let completeHandle = completeHandle {
                DispatchQueue.main.async {
                    completeHandle()
                }
            }
            
            
            }.resume()
    }
    
}
