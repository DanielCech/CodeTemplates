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

    var dependencies: Dependencies = (typeDependencies: Set([]), frameworkDependencies: Set([]))

    func prepareTemplate(context _: Context = mainContext) throws {
        let template = mainContext.stringValue(.template)
        let category = mainContext.stringValue(.category)
        let projectFiles = mainContext.stringArrayValue(.projectFiles)
        let name = mainContext.stringValue(.name)

        try prepareTemplateFolder(template: template, category: category)

        var deriveFromTemplate = mainContext.optionalStringValue(.deriveFromTemplate)
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
                name: name
            )
        }

        print("dependencies: \(dependencies)\n")

        _ = try DependencyAnalyzer.shared.findDefinitions(forTypeDependencies: dependencies.typeDependencies)
        try DependencyAnalyzer.shared.createPodfile(forFrameworkDependencies: dependencies.typeDependencies)
    }

    func prepareTemplate(
        forFile projectFile: String,
        template: Template,
        category: String,
        name: String
    ) throws {
        let templatePath = mainContext.stringValue(.templatePath).appendingPathComponent(path: category).appendingPathComponent(path: template)

        let inputFile = try File(path: projectFile)

        print("\(inputFile.name):")

        // Prepare target folder structure
        var templateDestination: TemplateDestination
        var projectSubPath = projectFile.deletingLastPathComponent.withoutSlash()

        if projectFile.deletingLastPathComponent.lowercased().withoutSlash() == mainContext.stringValue(.projectPath).lowercased().withoutSlash() {
            templateDestination = .project
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - mainContext.stringValue(.projectPath).count))
        } else if projectFile.lowercased().withoutSlash().starts(with: mainContext.stringValue(.locationPath).lowercased().withoutSlash()) {
            templateDestination = .location
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - mainContext.stringValue(.locationPath).count))
        } else if projectFile.lowercased().withoutSlash().starts(with: mainContext.stringValue(.sourcesPath).lowercased().withoutSlash()) {
            templateDestination = .sources
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - mainContext.stringValue(.sourcesPath).count))
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

        let fileDependencies = try DependencyAnalyzer.shared.analyzeFileDependencies(of: copiedFile)

        dependencies.typeDependencies = dependencies.typeDependencies.union(fileDependencies.typeDependencies)
        dependencies.frameworkDependencies = dependencies.typeDependencies.union(fileDependencies.frameworkDependencies)

        // TODO: temporary !!!
        //  return

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

        let parentTemplatePath = mainContext.stringValue(.templatePath)
            .appendingPathComponent(path: parentTemplateCategory)
            .appendingPathComponent(path: parentTemplate)

        let templatePath = mainContext.stringValue(.templatePath)
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

        let templatePath = mainContext.stringValue(.templatePath)
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
        let templatePath = mainContext.stringValue(.templatePath).appendingPathComponent(path: category).appendingPathComponent(path: template)
        try? FileManager.default.createDirectory(atPath: templatePath, withIntermediateDirectories: true, attributes: nil)
        let templateFolder = try Folder(path: templatePath)
        try templateFolder.empty(includingHidden: true)
    }
}
