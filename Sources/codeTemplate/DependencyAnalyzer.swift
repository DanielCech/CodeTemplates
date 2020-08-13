//
//  DependencyAnalyzer.swift
//  codeTemplate
//
//  Created by Daniel Cech on 31/07/2020.
//

import Files
import Foundation

typealias Dependencies = (typeDependencies: Set<String>, frameworkDependencies: Set<String>)

class DependencyAnalyzer {
    static let shared = DependencyAnalyzer()

    func analyzeFileDependencies(of file: File) throws -> Dependencies {
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

        return (typeDependencies: typeDependenciesSet, frameworkDependencies: frameworkDependenciesSet)
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

    func findDefinitions(forTypeDependencies dependencies: Set<String>) throws -> [String: String] {
        let sourcesFolder = try Folder(path: mainContext.stringValue(.sourcesPath))
        var resultsDict = [String: String]()

        for sourceFile in sourcesFolder.files.recursive.enumerated() {
            // Only swift files
            guard sourceFile.element.extension?.lowercased() == "swift" else { continue }
            guard let contents = try? sourceFile.element.readAsString() else { continue }

            print(sourceFile.element.path[sourcesFolder.path.count...])

            for line in contents.lines() {
                for dependency in dependencies {
                    let classResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "class ",
                        patternGenerator: RegExpPatterns.classDefinitionPattern
                    )

                    let structResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "struct ",
                        patternGenerator: RegExpPatterns.structDefinitionPattern
                    )

                    let enumResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "enum ",
                        patternGenerator: RegExpPatterns.enumDefinitionPattern
                    )

                    let protocolResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "protocol ",
                        patternGenerator: RegExpPatterns.protocolDefinitionPattern
                    )

                    let typealiasResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "typealias ",
                        patternGenerator: RegExpPatterns.typealiasDefinitionPattern
                    )

                    if (classResult ?? structResult ?? enumResult ?? protocolResult ?? typealiasResult) != nil {
                        resultsDict[dependency] = sourceFile.element.path
                    }
                }
            }
        }

        return resultsDict
    }

    func createPodfile(forFrameworkDependencies _: Set<String>) throws {}

    func patternMatch(line: String, dependency: String, easyCheck: String, patternGenerator: (String) -> String) throws -> NSTextCheckingResult? {
        if !line.contains(easyCheck) { return nil }
        return try line.regExpMatches(lineRegExp: patternGenerator(dependency)).first
    }
}
