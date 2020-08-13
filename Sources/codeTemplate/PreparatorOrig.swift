//
//  PreparatorOrig.swift
//  codeTemplate
//
//  Created by Daniel Cech on 17/07/2020.
//

import Files
import Foundation
import ScriptToolkit

class PreparatorOrig {
    public static let shared = PreparatorOrig()

    var dependencies: Dependencies = (typeDependencies: Set([]), frameworkDependencies: Set([]))

    func prepareTemplate() throws {
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

