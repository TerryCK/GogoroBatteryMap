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
