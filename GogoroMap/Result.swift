//
//  Result.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

enum Result<T> {
    case success(T)
    case fail(Error?)
}
