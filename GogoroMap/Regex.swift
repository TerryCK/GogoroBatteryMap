//
//  Regex.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/18.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import Foundation
public struct Regex {
    public let pattern: String
}

public protocol RegexMatchable : StringProtocol {
    static func ~=(regex: Regex, input: Self) -> Bool
    func match(regex: Regex) -> Bool
    func matches(with regex: Regex, options: NSRegularExpression.Options) -> [String]
    func capturedGroups(with regex: Regex, options: NSRegularExpression.Options) -> [String]
    func replacingOccurrences(regex: Regex, options: NSRegularExpression.Options = [], replacement: String) -> String
}

public extension RegexMatchable {
    
    var regex: Regex { return Regex(pattern: String(self)) }
    
    func match(regex: Regex) -> Bool {
        return regex ~= self
    }
    
    static func ~=(regex: Regex, input: Self) -> Bool {
        return String(input).range(of: regex.pattern, options: .regularExpression) != nil
    }
}

extension String : RegexMatchable {
    
    public func capturedGroups(with regex: Regex, options: NSRegularExpression.Options = []) -> [String] {
        return Array(matches(with: regex, options: options).dropFirst())
    }
    
    public func matches(with regex: Regex, options: NSRegularExpression.Options = []) -> [String] {
        guard let match = (try? NSRegularExpression(pattern: regex.pattern, options: options))?.firstMatch(in: self, options: [], range: NSRange(startIndex..., in: self)) else { return [] }
        return (0..<match.numberOfRanges).compactMap {
            return match.range(at: $0).location == NSNotFound ? nil : Range(match.range(at: $0), in: self).flatMap { String(self[$0]) }
        }
    }
    
    public func replacingOccurrences(regex: Regex, options: NSRegularExpression.Options = [], replacement: String) -> String {
        let regular = try? NSRegularExpression(pattern: regex.pattern, options: options)
        return regular?.stringByReplacingMatches(in: self, options: [], range: NSRange(startIndex..., in: self), withTemplate: replacement) ?? self
    }
}
