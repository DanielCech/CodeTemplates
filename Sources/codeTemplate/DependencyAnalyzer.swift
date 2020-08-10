//
//  DependencyAnalyzer.swift
//  codeTemplate
//
//  Created by Daniel Cech on 31/07/2020.
//

import Foundation
import Files

class DependencyAnalyzer {
    static let shared = DependencyAnalyzer()
    
    func analyzeFileDependencies(of file: File) throws {
        let contents = try file.readAsString()

        var typeDependencies = [String]()
        var frameworkDependencies = [String]()

        for line in contents.lines() {
            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.classPattern)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.structPattern)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.enumPattern)
            )
            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.protocolPattern)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.extensionPattern)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.letPattern1)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.letPattern2)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.varPattern1)
            )

            typeDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.varPattern2)
            )

            frameworkDependencies.append(
                contentsOf: try DependencyAnalyzer.shared.analyze(line: line, regExp: RegExpPatterns.importPattern)
            )
        }

        let typeDependenciesSet = Set(typeDependencies).subtracting(Internals.systemTypes)
        let frameworkDependenciesSet = Set(frameworkDependencies).subtracting(Internals.systemFrameworks)

        print("    🔎 Type dependencies: \(typeDependenciesSet)")
        print("    📦 Framework dependencies: \(frameworkDependenciesSet)")
    }

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
