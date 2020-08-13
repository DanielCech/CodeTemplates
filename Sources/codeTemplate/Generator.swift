//
//  Generator.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import PathKit
import ScriptToolkit
import Stencil

class Generator {
    static let shared = Generator()

    var processedFiles = [ProcessedFile]()

    /// Generate code using template with context in json file
    func generateCode(context: Context = mainContext) throws {
        let generationMode: GenerationMode
        if let unwrappedTemplate = context.optionalStringValue(.template) {
            generationMode = .template(unwrappedTemplate)
        } else if let unwrappedTemplateCombo = context.optionalStringValue(.templateCombo) {
            guard let comboType = TemplateCombo(rawValue: unwrappedTemplateCombo) else {
                throw CodeTemplateError.unknownTemplateCombo(message: unwrappedTemplateCombo)
            }
            generationMode = .combo(comboType)
        } else {
            throw ScriptError.moreInfoNeeded(message: "template or templateCombo are not specified or invalid")
        }

        try Generator.shared.generate(
            generationMode: generationMode,
            context: context,
            deleteGenerate: true
        )
    }

    /// Generate code using particular template
    func generate(
        generationMode: GenerationMode,
        context: Context,
        deleteGenerate: Bool = true,
        validationMode: Bool = false
    ) throws {
        switch generationMode {
        case let .template(templateType):
            try generateTemplate(templateType: templateType, context: context, deleteGenerate: deleteGenerate, validationMode: validationMode)

        case let .combo(comboType):
            try comboType.perform(context: context)
        }

        shell("/usr/local/bin/swiftformat \"\(context.stringValue(.scriptPath))\" > /dev/null 2>&1")

        try Reviewer.shared.review(processedFiles: processedFiles, context: context)
    }
}

private extension Generator {
    /// Generation of particular template
    func generateTemplate(
        templateType: Template,
        context: Context,
        deleteGenerate: Bool = true,
        validationMode: Bool = false
    ) throws {
        let templateCategory = try Templates.shared.templateCategory(for: templateType)
        let templateInfo = try Templates.shared.templateInfo(for: templateType)
        let templateFolder = try Folder(path: context.stringValue(.templatePath)).subfolder(at: templateCategory).subfolder(at: templateType)

        // Delete contents of Generate folder
        let generatedFolder = try Folder(path: context.stringValue(.generatePath))
        if deleteGenerate {
            try generatedFolder.empty(includingHidden: true)
        }

        let projectFolder = try Folder(path: context.stringValue(.projectPath))

        try traverse(
            templatePath: templateFolder.path,
            generatePath: generatedFolder.path,
            projectPath: projectFolder.path,
            context: context,
            templateInfo: templateInfo,
            validationMode: validationMode
        )

        // Generate also template dependencies
        try generateTemplateDependencies(templateInfo: templateInfo, validationMode: validationMode, context: context)
    }

    /// Generation of template dependencies
    func generateTemplateDependencies(
        templateInfo: TemplateInfo,
        validationMode _: Bool,
        context: Context
    ) throws {
        // Generate also template dependencies
        for dependency in templateInfo.dependencies {
            var dependencyName = dependency

            // Conditional dependency syntax: "template:condition1,condition2,..."; true if any of conditions is true
            if dependency.contains(":") {
                let parts = dependency.split(separator: ":")
                dependencyName = String(parts.first!)
                let conditions = parts.last!.split(separator: ",")

                var overallValue = false
                for condition in conditions {
                    if let conditionValue = context.dictionary[String(condition)] as? Bool, conditionValue {
                        overallValue = true
                        break
                    }
                }

                // Dependency has not fullfilled conditions
                if !overallValue {
                    continue
                }
            }

            try generateTemplate(templateType: dependencyName, context: context, deleteGenerate: false)
        }
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

    /// Recursive traverse thru template, generated and project folders
    func traverse(
        templatePath: String,
        generatePath: String,
        projectPath: String,
        context: Context,
        templateInfo: TemplateInfo,
        validationMode: Bool = false
    ) throws {
        let templateFolder = try Folder(path: templatePath)
        let generatedFolder = try Folder(path: generatePath)

        let environment = stencilEnvironment(templateFolder: templateFolder)

        // Process files in folder
        for file in templateFolder.files {
            try traverseProcessFile(
                context: context,
                file: file,
                templateInfo: templateInfo,
                templatePath: templatePath,
                generatePath: generatePath,
                projectPath: projectPath,
                environment: environment
            )
        }

        // Process subfolders
        for folder in templateFolder.subfolders {
            try traverseProcessSubfolder(
                context: context,
                folder: folder,
                templateInfo: templateInfo,
                validationMode: validationMode,
                generatedFolder: generatedFolder,
                projectPath: projectPath
            )
        }
    }

    func traverseProcessFile(
        context: Context,
        file: File,
        templateInfo: TemplateInfo,
        templatePath: String,
        generatePath: String,
        projectPath: String,
        environment: Environment
    ) throws {
        if file.name.lowercased() == "template.json"
            || file.name.lowercased().starts(with: "screenshot")
            || file.name.lowercased().starts(with: "description") {
            return
        }

        let outputFileName = file.name.generateName(context: context)

        let modifiedContext = Context(fromContext: context)
        modifiedContext[.fileName] = outputFileName

        let generatedFolder = try Folder(path: generatePath)
        let templateFolder = try Folder(path: templatePath)

        let templateFile = templatePath.appendingPathComponent(path: file.name)
        let generatedFile = generatePath.appendingPathComponent(path: outputFileName)
        var projectFile = projectPath.appendingPathComponent(path: outputFileName)

        // TODO: preferOriginalLocation implementation
        if templateInfo.preferOriginalLocation.contains(file.name) {
            let projectFolder = try Folder(path: context.stringValue(.projectPath))
            if let foundProjectFile = projectFolder.findFirstFile(name: outputFileName) {
                projectFile = foundProjectFile.path
            }
        }

        // Directly copy binary file
        guard var fileString = try? file.readAsString() else {
            let copiedFile = try file.copy(to: generatedFolder)
            try copiedFile.rename(to: outputFileName)
            return
        }

        let outputFile = try generatedFolder.createFile(named: outputFileName)

        var rendered: String
        do {
            // Stencil expressions {% for %} needs to be placed at the end of last line to prevent extra linespaces in generated code
            let matches = try! fileString.regExpStringMatches(lineRegExp: #"\n^\w*\{% for .*%\}$"#)

            for match in matches {
                fileString = fileString.replacingOccurrences(of: match, with: " " + match.suffix(match.count - 1))
            }

            rendered = try environment.renderTemplate(string: fileString, context: modifiedContext.dictionary)
        } catch {
            throw CodeTemplateError.stencilTemplateError(message: "\(templateFolder.path): \(file.name): \(error.localizedDescription)")
        }

        try outputFile.write(rendered)

        processedFiles.append((templateFile: templateFile, generatedFile: generatedFile, projectFile: projectFile))
    }

    func traverseProcessSubfolder(
        context: Context,
        folder: Folder,
        templateInfo: TemplateInfo,
        validationMode: Bool,
        generatedFolder: Folder,
        projectPath: String
    ) throws {
        var baseGeneratePath: String
        var baseProjectPath: String

        switch folder.name {
        case "_project":
            try traverse(
                templatePath: folder.path,
                generatePath: generatedFolder.path,
                projectPath: context.stringValue(.projectPath),
                context: context,
                templateInfo: templateInfo
            )

        case "_sources":
            if validationMode {
                baseGeneratePath = generatedFolder.path
            } else {
                baseGeneratePath = try generatedFolder.createSubfolder(at: context.stringValue(.sourcesPath).lastPathComponent).path
            }

            baseProjectPath = context.stringValue(.sourcesPath)

            try traverse(
                templatePath: folder.path,
                generatePath: baseGeneratePath,
                projectPath: baseProjectPath,
                context: context,
                templateInfo: templateInfo
            )

        case "_location":
            let subPath = String(context.stringValue(.locationPath).suffix(context.stringValue(.locationPath).count - context.stringValue(.projectPath).count))

            if validationMode {
                baseGeneratePath = generatedFolder.path
            } else {
                baseGeneratePath = try generatedFolder.createSubfolder(at: subPath).path
            }

            baseProjectPath = context.stringValue(.locationPath)

            try traverse(
                templatePath: folder.path,
                generatePath: baseGeneratePath,
                projectPath: baseProjectPath,
                context: context,
                templateInfo: templateInfo
            )

        default:
            let outputFolder = folder.name.generateName(context: context)
            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)

            try traverse(
                templatePath: folder.path,
                generatePath: generatedSubFolder.path,
                projectPath: projectPath.appendingPathComponent(path: outputFolder),
                context: context,
                templateInfo: templateInfo
            )
        }
    }
}
