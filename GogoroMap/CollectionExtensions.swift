//
//  CollectionExtensions.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 19/09/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//


import MapKit
import CloudKit
import Foundation

typealias StationDatas = (total: Int, available: Int, hasFlags: Int, hasCheckins: Int)

extension Collection where Element: CustomPointAnnotation {
    //MARK: - Get the station informations count of total,available,hasFlags,hasCheckins
//    var getStationData: StationDatas {
//        return reduce((0,0,0,0)) {  ($0.0 + 1, $0.1 + ($1.isOpening ? 1 : 0) , $0.2 + ($1.checkinCounter > 0 ? 1 : 0), $0.3 + $1.checkinCounter)  }
//    }
}


extension Collection where Element == BackupData {
    var toCustomTableViewCell: [CustomTableViewCell] {
        let upperLimit = 10
        return enumerated().flatMap { (index, element) -> CustomTableViewCell? in
            guard index < upperLimit, let data = element.data,
            let stations = try? JSONDecoder().decode([Response.Station].self, from: data) else { return nil }
            
            let size = ByteCountFormatter {
                $0.allowedUnits = [.useAll]
                $0.countStyle = .file
                }.string(fromByteCount: Int64(data.count))
            
            let totalCheckin = stations.reduce(0) { $0 + ($1.checkinCounter ?? 0) }
            
            
            return CustomTableViewCell(type: .backupButton,
                                       title: " \(index + 1). \(element.timeInterval?.toTimeString ?? "" )",
                                       subtitle: "         \(size)      打卡次數：\(totalCheckin)")
        }
    }
    
}
