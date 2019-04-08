//
//  CellConfigurable.swift
//  iOS-188Asia
//
//  Created by Terry Chen on 05/03/2018.
//  Copyright © 2018 Xuenn Pte Ltd. All rights reserved.
//

public protocol CaseIterable: Hashable {
    associatedtype AllCases: Collection where AllCases.Element == Self
    static var allCases: AllCases { get }
}

public protocol CaseNameConvertible {
    var caseName: String { get }
}

extension CaseNameConvertible {
    public var caseName: String { return String(describing: self) }
}

extension CaseIterable {
    public static var allCases: [Self]  { return Array(Self.cases()) }
    
    private static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var index = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &index) {
                    $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == index else { return nil }
                index += 1
                return current
            }
        }
    }
}

