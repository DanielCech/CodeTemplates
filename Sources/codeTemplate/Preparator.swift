//
//  Preparator.swift
//  codeTemplate
//
//  Created by Daniel Cech on 17/07/2020.
//

import Files
import Foundation
import ScriptToolkit

class Preparator {
    public static let shared = Preparator()

    func prepareTemplate(context: Context) throws {
        guard let template = context["template"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "template")
        }

        guard let category = context["category"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "category")
        }

        guard let projectFiles = context["projectFiles"] as? [String] else {
            throw CodeTemplateError.parameterNotSpecified(message: "projectFiles")
        }

        guard let name = context["name"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "name")
        }

        try Paths.setupPaths()
        try prepareTemplateFolder(template: template, category: category)

        var deriveFromTemplate = context["deriveFromTemplate"] as? String
        if deriveFromTemplate == nil {
            print("🟢 Derive from which template (empty for none): ", terminator: "")
            if let userInput = readLine(), !userInput.isEmpty {
                try Templates.shared.updateTemplateDerivations(template: template, deriveFromTemplate: userInput)
                deriveFromTemplate = userInput
                try createTemplateJSON(template: template, category: category, deriveFromTemplate: deriveFromTemplate!)
            } else {
                try createEmptyTemplateJSON(template: template, category: category)
            }
        }

        for projectFile in projectFiles {
            try prepareTemplate(
                forFile: projectFile,
                template: template,
                category: category,
                name: name,
                context: context
            )
        }
    }

    func prepareTemplate(
        forFile projectFile: String,
        template: Template,
        category: String,
        name: String,
        context _: Context
    ) throws {
        let templatePath = Paths.templatePath.appendingPathComponent(path: category).appendingPathComponent(path: template)

        let inputFile = try File(path: projectFile)

        // Prepare target folder structure
        var templateDestination: TemplateDestination
        var projectSubPath = projectFile.deletingLastPathComponent.withoutSlash()

        if projectFile.deletingLastPathComponent.lowercased().withoutSlash() == Paths.projectPath.lowercased().withoutSlash() {
            templateDestination = .project
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - Paths.projectPath.count))
        } else if projectFile.lowercased().withoutSlash().starts(with: Paths.locationPath.lowercased().withoutSlash()) {
            templateDestination = .location
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - Paths.locationPath.count))
        } else if projectFile.lowercased().withoutSlash().starts(with: Paths.sourcesPath.lowercased().withoutSlash()) {
            templateDestination = .sources
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - Paths.sourcesPath.count))
        } else {
            throw CodeTemplateError.invalidProjectFilePath(message: projectFile)
        }

        let templateSubPath = templatePath.appendingPathComponent(path: templateDestination.rawValue)
        try? FileManager.default.createDirectory(atPath: templateSubPath, withIntermediateDirectories: true, attributes: nil)

//        if !projectSubPath.isEmpty {
        let templateDestinationPath = templateSubPath.appendingPathComponent(path: projectSubPath)
        try? FileManager.default.createDirectory(atPath: templateDestinationPath, withIntermediateDirectories: true, attributes: nil)

        let templateDestinationFolder = try Folder(path: templateDestinationPath)
        let copiedFile = try inputFile.copy(to: templateDestinationFolder)

        try analyzeFileDependencies(of: copiedFile)
        try prepareTemplate(for: copiedFile, name: name)

        try copiedFile.rename(to: copiedFile.name.prepareName(name: name), keepExtension: false)

//        let copiedFile = try file.copy(to: generatedFolder)
//        try copiedFile.rename(to: outputFileName)
//            continue
//        }
    }
}

private extension Preparator {
    func createTemplateJSON(
        template: Template,
        category: String,
        deriveFromTemplate parentTemplate: Template
    ) throws {
        let parentTemplateCategory = try Templates.shared.templateCategory(for: parentTemplate)

        let parentTemplatePath = Paths.templatePath
            .appendingPathComponent(path: parentTemplateCategory)
            .appendingPathComponent(path: parentTemplate)

        let templatePath = Paths.templatePath
            .appendingPathComponent(path: category)
            .appendingPathComponent(path: template)

        let parentTemplateFolder = try Folder(path: parentTemplatePath)
        let templareFolder = try Folder(path: templatePath)

        let parentTemplateJSON = try parentTemplateFolder.file(named: "templare.json")
        try parentTemplateJSON.copy(to: templareFolder)
    }

    func createEmptyTemplateJSON(
        template: Template,
        category: String
    ) throws {
        let json = """
        {
          "context": {},
          "switches": []
        }
        """

        let templatePath = Paths.templatePath
            .appendingPathComponent(path: category)
            .appendingPathComponent(path: template)

        let templateFolder = try Folder(path: templatePath)
        let jsonFile = try templateFolder.createFile(named: "template.json")
        try jsonFile.write(json, encoding: .utf8)
    }

    func prepareTemplate(for file: File, name: String) throws {
        let contents = try file.readAsString()
        var newContents = contents
        var comment = ""

        if file.extension?.lowercased() == "swift" {
            for line in contents.lines() {
                if line.starts(with: "//") {
                    comment += line + "\n"
                } else {
                    let newComment =
                        """
                        //
                        //  {{fileName}}
                        //  {{projectName}}
                        //
                        //  Created by {{author}} on {{date}}.
                        //  {{copyright}}
                        //

                        """
                    newContents = newContents.replacingOccurrences(of: comment, with: newComment)
                    break
                }
            }
        } else {
            newContents = contents
        }

        newContents = newContents.replacingOccurrences(of: name.camelCased(), with: "{{name}}")
        newContents = newContents.replacingOccurrences(of: name.pascalCased(), with: "{{Name}}")

        // Generalize coordinator
        newContents = newContents.stringByReplacingMatches(
            pattern: "var coordinator: (.*)Coordinating!",
            withTemplate: "var coordinator: {{coordinator}}Coordinating!"
        )

        try file.write(newContents)
    }

    func prepareTemplateFolder(template: Template, category: String) throws {
        // Create template folder
        let templatePath = Paths.templatePath.appendingPathComponent(path: category).appendingPathComponent(path: template)
        try? FileManager.default.createDirectory(atPath: templatePath, withIntermediateDirectories: true, attributes: nil)
        let templateFolder = try Folder(path: templatePath)
        try templateFolder.empty(includingHidden: true)
    }

    func analyzeFileDependencies(of file: File) throws {
        let contents = try file.readAsString()

        var typeDependencies = [String]()
        var frameworkDependencies = [String]()
        
        for line in contents.lines() {
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.classPattern))
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.structPattern))
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.enumPattern))
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.protocolPattern))
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.extensionPattern))
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.letPattern))
            typeDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.varPattern))
            
            frameworkDependencies.append(contentsOf: try analyze(line: line, regExp: RegExpPatterns.importPattern))
        }

        let typeDependenciesSet = Set(typeDependencies).subtracting(Internals.systemTypes)
        let frameworkDependenciesSet = Set(frameworkDependencies).subtracting(Internals.systemFrameworks)
        
        
        print("🔎 Type dependencies: \(typeDependenciesSet)")
        print("📦 Framework dependencies: \(frameworkDependenciesSet)")
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
