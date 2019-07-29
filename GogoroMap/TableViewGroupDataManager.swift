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
    init<T: Sequence>(_ s: T, groupKey: (T.Element) -> String) where T.Element == Element {
        array = Array(Dictionary(grouping: s, by: groupKey))
    }
    
    init<S: Sequence>(_ s: S) where S.Element == Element {
        array = Array(Dictionary(grouping: s, by: { _ in "" }))
    }

    func sorted(by handler: ((Group, Group) throws -> Bool)) rethrows -> TableViewGroupDataManager {
        return try TableViewGroupDataManager(array: array.sorted(by: handler))
    }
    
    func sortedValue(by handler: ((Element, Element) throws -> Bool)) rethrows -> TableViewGroupDataManager {
        return try TableViewGroupDataManager(array: array.map { ($0.key, try $0.value.sorted(by: handler)) })
    }
    
    func filter(_ handler: ((Element) -> Bool) ) -> TableViewGroupDataManager {
        let fetchResult = array.compactMap { element -> (String, [Element])? in
            let result = element.value.filter(handler)
            return result.isEmpty ? nil : (element.key, result)
        }
        return TableViewGroupDataManager(array: fetchResult)
    }
}

extension TableViewGroupDataManager where Element == BatteryStationPointAnnotation {
   
    
    func filter(searchText: String) -> TableViewGroupDataManager {
        guard !searchText.isEmpty else {
            return self
        }
        let keywords = searchText.replacingOccurrences(regex: "臺".regex, replacement: "台")
        return filter { $0.address.contains(keywords) || $0.title?.contains(keywords) ?? false }
    }
}

extension TableViewGroupDataManager: CustomStringConvertible {
    var description: String {
        return array.reduce("\(String(describing: type(of: self))) \n\n") { $0 + "section: " + $1.key + "\n" + $1.value.reduce("  Elements: \n") { $0 + "    " + String(describing: $1) + "\n" } + "\n" }
    }
}
