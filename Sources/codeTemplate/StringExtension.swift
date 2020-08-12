//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
    /// Conversion to PascalCase
    func pascalCased() -> String {
        let first = String(prefix(1)).uppercased()
        let other = String(dropFirst())
        return first + other
    }

    /// Conversion to PascalCase
    mutating func pascalCase() {
        self = pascalCased()
    }

    /// Conversion to camelCase
    func camelCased() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }

    /// Conversion to camelCase
    mutating func camelCase() {
        self = camelCased()
    }

    /// File name modification based on substitutions from context
    func generateName(context: Context) -> String {
        var newName = replacingOccurrences(of: ".stencil", with: "")
        for key in context.dictionary.keys {
            guard let stringValue = context.dictionary[key] as? String else { continue }
            newName = newName.replacingOccurrences(of: "{{\(key)}}", with: stringValue)
        }
        return newName
    }

    /// File name modification based on substitutions from context
    func prepareName(name: String) -> String {
        var newName = replacingOccurrences(of: name.pascalCased(), with: "{{Name}}")
        newName.append(".stencil")
        return newName
    }

    /// Regular expression matches
    func regExpMatches(lineRegExp: String) throws -> [NSTextCheckingResult] {
        let nsrange = NSRange(startIndex..<endIndex, in: self)
        let regex = try NSRegularExpression(pattern: lineRegExp, options: [.anchorsMatchLines])
        let matches = regex.matches(in: self, options: [], range: nsrange)
        return matches
    }

    /// Regular expression matches
    func regExpStringMatches(lineRegExp: String) throws -> [String] {
        let matches = try regExpMatches(lineRegExp: lineRegExp)

        let ranges = matches.map { Range($0.range, in: self)! }
        let substrings = ranges.map { self[$0] }
        let strings = substrings.map { String($0) }
        return strings
    }

    func withoutSlash() -> String {
        if last == "/" {
            return String(prefix(count - 1))
        }
        return self
    }

    func stringByReplacingMatches(pattern: String, withTemplate template: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern)
        return regex.stringByReplacingMatches(
            in: self,
            options: .reportCompletion,
            range: NSRange(location: 0, length: count),
            withTemplate: template
        )
    }
}
