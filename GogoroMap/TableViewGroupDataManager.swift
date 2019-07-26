//
//  TableViewGroupDataManager.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/18.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import Foundation

protocol TableViewGroupDataSource {
    associatedtype Element
    var numberOfSection: Int { get }
    subscript(indexPath: IndexPath) -> Element { get }
    func numberOfRowsInSection(indexPath: IndexPath) -> Int
    func title(indexPath: IndexPath) -> String
    
}

struct TableViewGroupDataManager<Element>: TableViewGroupDataSource {
    typealias Group = (key: String, value: Array<Element>)
    private let array: [Group]
    var numberOfSection: Int { return array.count }
    subscript(indexPath: IndexPath) -> Element              {  return array[indexPath.section].value[indexPath.row]  }
    func numberOfRowsInSection(indexPath: IndexPath) -> Int {  return array[indexPath.section].value.count }
    func title(indexPath: IndexPath) -> String              {  return array[indexPath.section].key }

}

extension TableViewGroupDataManager {
    func reduce<Result>(_ initialResult: Result, nextPartialResult: (Result, Group) throws -> Result) rethrows -> Result {
        return try array.reduce(initialResult, nextPartialResult)
    }
    
    
    func filter(by hanlder: ((key: String, value: Array<Element>)) -> Bool) -> TableViewGroupDataManager {
        return TableViewGroupDataManager(array: array.filter(hanlder))
    }
}
extension TableViewGroupDataManager {
    init<T: Sequence>(_ s: T, closure: (T.Element) -> String) where T.Element == Element {
        array = Array(Dictionary(grouping: s, by: closure)).sorted { $0.key > $1.key }
    }
    
    init<S: Sequence>(_ s: S) where S.Element == Element  {
        array = []
    }
}

extension TableViewGroupDataManager: CustomStringConvertible {
    var description: String {
        return array.reduce("\(String(describing: type(of: self))) \n\n") { $0 + "section: " + $1.key + "\n" + $1.value.reduce("  Elements: \n") { $0 + "    " + String(describing: $1) + "\n" } + "\n" }
    }
}
