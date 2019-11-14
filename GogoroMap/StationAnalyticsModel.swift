//
//  StationAnalyticsModel.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 17/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation

struct StationAnalyticsModel {
    let total, availables, flags, checkins: Int
    var buildings: Int { total - availables }
    var completedPercentage: String {  String(format: "%.1f", percentageOfCheckins) }
    private var percentageOfCheckins: Double { Double(flags) / Double(availables) * 100}
}

extension StationAnalyticsModel {
    init<T: BatteryDataModalProtocol>(_ stations: [T]) {
        total       = stations.count
        availables  = stations.reduce(0) { $0 +  ($1.isOperating ? 1 : 0) }
        flags       = stations.reduce(0) { $0 + (($1.checkinCounter ?? 0) > 0 ? 1 : 0) }
        checkins    = stations.reduce(0) { $0 + ($1.checkinCounter ?? 0) }
    }
}
