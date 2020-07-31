//
//  DependencyAnalyzer.swift
//  codeTemplate
//
//  Created by Daniel Cech on 31/07/2020.
//

import Foundation

class DependencyAnalyzer {
    static let shared = DependencyAnalyzer()
    
    func analyze(line: String, regExp: String) throws -> [String] {
        let results = try line.regExpMatches(lineRegExp: regExp)
        var array = [String]()

        for result in results {
            // Process comma separated values
            if let list = extract(line: line, match: result, component: "commalist") {
                let separated = list.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                array.append(contentsOf: separated)
            }

            // Process first part of name
            if let item = extract(line: line, match: result, component: "singleName") {
                if let itemResult = try item.regExpMatches(lineRegExp: RegExpPatterns.singleNamePattern).first {
                    if let name = extract(line: line, match: itemResult, component: "name") {
                        array.append(name)
                    }
                }
            }

            // Exact result
            if let name = extract(line: line, match: result, component: "name") {
                array.append(name)
            }
        }

        return array
    }

    func extract(line: String, match: NSTextCheckingResult, component: String) -> String? {
        let nsrange = match.range(withName: component)

        guard
            nsrange.location != NSNotFound,
            let range = Range(nsrange, in: line)
        else {
            return nil
        }

        return String(line[range])
    }
    
}
