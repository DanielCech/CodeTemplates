//
//  Preparator.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import PathKit
import ScriptToolkit
import Stencil

class Preparator {
    static let shared = Preparator()

    var processedFiles = [ProcessedFile]()
    var dependencies: Dependencies = (typeDependencies: Set([]), frameworkDependencies: Set([]))

    /// Generate code using particular template
    func prepareTemplate(
        context: Context,
        deletePrepare: Bool = true
    ) throws {
        try prepareTemplateCore(
            context: context,
            deletePrepare: deletePrepare
        )

        // shell("/usr/local/bin/swiftformat \"\(context.stringValue(.scriptPath))\" > /dev/null 2>&1")

        try Reviewer.shared.review(processedFiles: processedFiles, context: context)
    }
}

private extension Preparator {
    /// Generation of particular template
    func prepareTemplateCore(
        context: Context,
        deletePrepare: Bool = true
    ) throws {
        let template = mainContext.stringValue(.template)
        let category = context.stringValue(.category)
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

        // Delete contents of Prepare folder
        let prepareFolder = try Folder(path: context.stringValue(.preparePath))
        if deletePrepare {
            try prepareFolder.empty(includingHidden: true)

            // Reset dependencies
            dependencies = (typeDependencies: Set([]), frameworkDependencies: Set([]))
        }

        for projectFilePath in projectFiles {
            try prepareTemplate(
                context: context,
                projectFilePath: projectFilePath,
                template: template,
                category: category,
                name: name
            )
        }

        print("\n⚙️ Type dependencies: \(Array(dependencies.typeDependencies))")
        print("\n⚙️ Framework dependencies: \(Array(dependencies.frameworkDependencies))\n")

        print("🔎 Searching for type dependencies definitions:")
        let result = try DependencyAnalyzer.shared.findDefinitions(forTypeDependencies: dependencies.typeDependencies)
        print("🔎 Searching done\n")

        print("⚠️ Unprocessed dependencies:")
        let list = result.values
        print(list)

        try DependencyAnalyzer.shared.createPodfile(forFrameworkDependencies: dependencies.frameworkDependencies)
    }

    func prepareTemplate(
        context: Context,
        projectFilePath: String,
        template: Template,
        category: String,
        name: String
    ) throws {
        let templatePath = context.stringValue(.templatePath).appendingPathComponent(path: category).appendingPathComponent(path: template)
        let preparePath = context.stringValue(.preparePath)

        let projectFile = try File(path: projectFilePath)

        print("\(projectFile.name):")

        // Prepare target folder structure
        var templateDestination: TemplateDestination
        var projectSubPath = projectFilePath.deletingLastPathComponent.withoutSlash()

        if projectFilePath.deletingLastPathComponent.lowercased().withoutSlash() == mainContext.stringValue(.projectPath).lowercased().withoutSlash() {
            templateDestination = .project
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - mainContext.stringValue(.projectPath).count))
        } else if projectFilePath.lowercased().withoutSlash().starts(with: mainContext.stringValue(.locationPath).lowercased().withoutSlash()) {
            templateDestination = .location
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - mainContext.stringValue(.locationPath).count))
        } else if projectFilePath.lowercased().withoutSlash().starts(with: mainContext.stringValue(.sourcesPath).lowercased().withoutSlash()) {
            templateDestination = .sources
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - mainContext.stringValue(.sourcesPath).count))
        } else {
            throw CodeTemplateError.invalidProjectFilePath(message: projectFilePath)
        }

        let templateSubPath = templatePath.appendingPathComponent(path: templateDestination.rawValue)
        let prepareSubPath = preparePath.appendingPathComponent(path: templateDestination.rawValue)
        try? FileManager.default.createDirectory(atPath: prepareSubPath, withIntermediateDirectories: true, attributes: nil)

//        if !projectSubPath.isEmpty {
        let templateDestinationPath = templateSubPath.appendingPathComponent(path: projectSubPath)
        let prepareDestinationPath = prepareSubPath.appendingPathComponent(path: projectSubPath)
        try? FileManager.default.createDirectory(atPath: prepareDestinationPath, withIntermediateDirectories: true, attributes: nil)

        let prepareDestinationFolder = try Folder(path: prepareDestinationPath)
        let prepareCopiedFile = try projectFile.copy(to: prepareDestinationFolder)

        let fileDependencies = try DependencyAnalyzer.shared.analyzeFileDependencies(of: prepareCopiedFile)

        dependencies.typeDependencies = dependencies.typeDependencies.union(fileDependencies.typeDependencies)
        dependencies.frameworkDependencies = dependencies.typeDependencies.union(fileDependencies.frameworkDependencies)

        // TODO: temporary !!!
        //  return

        try prepareTemplate(for: prepareCopiedFile, name: name)

        let preparedFileNewName = prepareCopiedFile.name.prepareName(name: name)
        try prepareCopiedFile.rename(to: preparedFileNewName, keepExtension: false)

        let templateFile = templateDestinationPath.appendingPathComponent(path: preparedFileNewName)
        let preparedFile = prepareDestinationPath.appendingPathComponent(path: preparedFileNewName)

        processedFiles.append((templateFile: templateFile, middleFile: preparedFile, projectFile: projectFilePath))

//        let copiedFile = try file.copy(to: generatedFolder)
//        try copiedFile.rename(to: outputFileName)
//            continue
//        }
    }

    /// Definition of stencil environment with support of custom filters
    func stencilEnvironment(templateFolder: Folder) -> Environment {
        let ext = Extension()

        ext.registerFilter("camelCased") { (value: Any?) in
            if let value = value as? String {
                return value.camelCased()
            }

            return value
        }

        ext.registerFilter("pascalCased") { (value: Any?) in
            if let value = value as? String {
                return value.pascalCased()
            }

            return value
        }

        let environment = Environment(loader: FileSystemLoader(paths: [Path(templateFolder.path)]), extensions: [ext])
        return environment
    }

//    /// Recursive traverse thru template, generated and project folders
//    func traverse(
//        templatePath: String,
//        generatePath: String,
//        projectPath: String,
//        context: Context,
//        templateInfo: TemplateInfo,
//        validationMode: Bool = false
//    ) throws {
//        let templateFolder = try Folder(path: templatePath)
//        let generatedFolder = try Folder(path: generatePath)
//
//        let environment = stencilEnvironment(templateFolder: templateFolder)
//
//        // Process files in folder
//        for file in templateFolder.files {
//            try traverseProcessFile(
//                context: context,
//                file: file,
//                templateInfo: templateInfo,
//                templatePath: templatePath,
//                generatePath: generatePath,
//                projectPath: projectPath,
//                environment: environment
//            )
//        }
//
//        // Process subfolders
//        for folder in templateFolder.subfolders {
//            try traverseProcessSubfolder(
//                context: context,
//                folder: folder,
//                templateInfo: templateInfo,
//                validationMode: validationMode,
//                generatedFolder: generatedFolder,
//                projectPath: projectPath
//            )
//        }
//    }
//
//    func traverseProcessFile(
//        context: Context,
//        file: File,
//        templateInfo: TemplateInfo,
//        templatePath: String,
//        generatePath: String,
//        projectPath: String,
//        environment: Environment
//    ) throws {
//        if file.name.lowercased() == "template.json"
//            || file.name.lowercased().starts(with: "screenshot")
//            || file.name.lowercased().starts(with: "description") {
//            return
//        }
//
//        let outputFileName = file.name.generateName(context: context)
//
//        let modifiedContext = Context(fromContext: context)
//        modifiedContext[.fileName] = outputFileName
//
//        let generatedFolder = try Folder(path: generatePath)
//        let templateFolder = try Folder(path: templatePath)
//
//        let templateFile = templatePath.appendingPathComponent(path: file.name)
//        let generatedFile = generatePath.appendingPathComponent(path: outputFileName)
//        var projectFile = projectPath.appendingPathComponent(path: outputFileName)
//
//        // TODO: preferOriginalLocation implementation
//        if templateInfo.preferOriginalLocation.contains(file.name) {
//            let projectFolder = try Folder(path: context.stringValue(.projectPath))
//            if let foundProjectFile = projectFolder.findFirstFile(name: outputFileName) {
//                projectFile = foundProjectFile.path
//            }
//        }
//
//        // Directly copy binary file
//        guard var fileString = try? file.readAsString() else {
//            let copiedFile = try file.copy(to: generatedFolder)
//            try copiedFile.rename(to: outputFileName)
//            return
//        }
//
//        let outputFile = try generatedFolder.createFile(named: outputFileName)
//
//        var rendered: String
//        do {
//            // Stencil expressions {% for %} needs to be placed at the end of last line to prevent extra linespaces in generated code
//            let matches = try! fileString.regExpStringMatches(lineRegExp: #"\n^\w*\{% for .*%\}$"#)
//
//            for match in matches {
//                fileString = fileString.replacingOccurrences(of: match, with: " " + match.suffix(match.count - 1))
//            }
//
//            rendered = try environment.renderTemplate(string: fileString, context: modifiedContext.dictionary)
//        } catch {
//            throw CodeTemplateError.stencilTemplateError(message: "\(templateFolder.path): \(file.name): \(error.localizedDescription)")
//        }
//
//        try outputFile.write(rendered)
//
//        processedFiles.append((templateFile: templateFile, generatedFile: generatedFile, projectFile: projectFile))
//    }
//
//    func traverseProcessSubfolder(
//        context: Context,
//        folder: Folder,
//        templateInfo: TemplateInfo,
//        validationMode: Bool,
//        generatedFolder: Folder,
//        projectPath: String
//    ) throws {
//        var baseGeneratePath: String
//        var baseProjectPath: String
//
//        switch folder.name {
//        case "_project":
//            try traverse(
//                templatePath: folder.path,
//                generatePath: generatedFolder.path,
//                projectPath: context.stringValue(.projectPath),
//                context: context,
//                templateInfo: templateInfo
//            )
//
//        case "_sources":
//            if validationMode {
//                baseGeneratePath = generatedFolder.path
//            } else {
//                baseGeneratePath = try generatedFolder.createSubfolder(at: context.stringValue(.sourcesPath).lastPathComponent).path
//            }
//
//            baseProjectPath = context.stringValue(.sourcesPath)
//
//            try traverse(
//                templatePath: folder.path,
//                generatePath: baseGeneratePath,
//                projectPath: baseProjectPath,
//                context: context,
//                templateInfo: templateInfo
//            )
//
//        case "_location":
//            let subPath = String(context.stringValue(.locationPath).suffix(context.stringValue(.locationPath).count - context.stringValue(.projectPath).count))
//
//            if validationMode {
//                baseGeneratePath = generatedFolder.path
//            } else {
//                baseGeneratePath = try generatedFolder.createSubfolder(at: subPath).path
//            }
//
//            baseProjectPath = context.stringValue(.locationPath)
//
//            try traverse(
//                templatePath: folder.path,
//                generatePath: baseGeneratePath,
//                projectPath: baseProjectPath,
//                context: context,
//                templateInfo: templateInfo
//            )
//
//        default:
//            let outputFolder = folder.name.generateName(context: context)
//            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)
//
//            try traverse(
//                templatePath: folder.path,
//                generatePath: generatedSubFolder.path,
//                projectPath: projectPath.appendingPathComponent(path: outputFolder),
//                context: context,
//                templateInfo: templateInfo
//            )
//        }
//    }
}

private extension Preparator {
    func createTemplateJSON(
        template: Template,
        category: String,
        deriveFromTemplate parentTemplate: Template
    ) throws {
        // Temporary json to prevent error
        try createEmptyTemplateJSON(template: template, category: category)

        let parentTemplateCategory = try Templates.shared.templateCategory(for: parentTemplate)

        let parentTemplatePath = mainContext.stringValue(.templatePath)
            .appendingPathComponent(path: parentTemplateCategory)
            .appendingPathComponent(path: parentTemplate)

        let templatePath = mainContext.stringValue(.templatePath)
            .appendingPathComponent(path: category)
            .appendingPathComponent(path: template)

        let parentTemplateFolder = try Folder(path: parentTemplatePath)
        let templareFolder = try Folder(path: templatePath)

        try deleteTemplateJSON(template: template, category: category)

        let parentTemplateJSON = try parentTemplateFolder.file(named: "template.json")
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

        if templateFolder.containsFile(named: "template.json") {
            return
        }

        let jsonFile = try templateFolder.createFile(named: "template.json")
        try jsonFile.write(json, encoding: .utf8)
    }

    func deleteTemplateJSON(template: Template, category: String) throws {
        let templatePath = mainContext.stringValue(.templatePath)
            .appendingPathComponent(path: category)
            .appendingPathComponent(path: template)

        let templateFolder = try Folder(path: templatePath)
        let templateFile = try templateFolder.file(named: "template.json")
        try templateFile.delete()
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
