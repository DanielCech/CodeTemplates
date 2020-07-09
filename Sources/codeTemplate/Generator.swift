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

    func generateCode(contextFile: String, reviewMode: ReviewMode) throws {
        let contextFile = try File(path: contextFile)
        let contextString = try contextFile.readAsString(encodedAs: .utf8)
        let contextData = Data(contextString.utf8)

        // make sure this JSON is in the format we expect
        guard let context = try JSONSerialization.jsonObject(with: contextData, options: []) as? [String: Any] else {
            throw ScriptError.generalError(message: "Deserialization error")
        }

        let generationMode: GenerationMode
        if let unwrappedTemplate = context["template"] as? String {
            generationMode = .template(unwrappedTemplate)
        } else if let unwrappedTemplateCombo = context["templateCombo"] as? String, let comboType = TemplateCombo(rawValue: unwrappedTemplateCombo) {
            generationMode = .combo(comboType)
        } else {
            throw ScriptError.moreInfoNeeded(message: "template or templateCombo are not specified or invalid")
        }

        try Paths.setupPaths(context: context)

        let modifiedContext = ContextHelper.shared.updateContext(context)
        try Generator.shared.generate(
            generationMode: generationMode,
            context: modifiedContext,
            reviewMode: reviewMode,
            deleteGenerated: true
        )
    }

    func generate(
        generationMode: GenerationMode,
        context: Context,
        reviewMode: ReviewMode = .none,
        deleteGenerated: Bool = true,
        outputPath: String = Paths.generatedPath,
        validationMode: Bool = false
    ) throws {
        switch generationMode {
        case let .template(templateType):

            let templateCategory = try Templates.shared.templateCategory(for: templateType)
            let templateFolder = try Folder(path: Paths.templatePath).subfolder(at: templateCategory).subfolder(at: templateType)

            // Delete contents of Generated folder
            let generatedFolder = try Folder(path: outputPath)
            if deleteGenerated {
                try generatedFolder.empty(includingHidden: true)
            }

            let projectFolder = try Folder(path: Paths.projectPath)

            try traverse(
                templateFolder: templateFolder,
                generatedFolder: generatedFolder,
                projectFolder: projectFolder,
                context: context,
                outputPath: outputPath,
                validationMode: validationMode
            )

        case let .combo(comboType):
            try comboType.perform(context: context)
        }

        shell("/usr/local/bin/swiftformat \"\(Paths.scriptPath)\" > /dev/null 2>&1")

        try Reviewer.shared.review(mode: reviewMode, processedFiles: processedFiles)
    }
}

private extension Generator {
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

    func traverse(
        templateFolder: Folder,
        generatedFolder: Folder,
        projectFolder: Folder?,
        context: Context,
        outputPath: String = Paths.generatedPath,
        validationMode: Bool = false
    ) throws {
        var modifiedContext = context

        let environment = stencilEnvironment(templateFolder: templateFolder)

        // Process files in folder
        for file in templateFolder.files {
            if file.name.lowercased() == "template.json" { continue }

            let outputFileName = file.name.modifyName(context: context)
            modifiedContext["fileName"] = outputFileName

            let templateFile = templateFolder.path.appendingPathComponent(path: file.name)
            let generatedFile = generatedFolder.path.appendingPathComponent(path: outputFileName)

            let projectFile: String?
            if let unwrappedProjectFolder = projectFolder {
                projectFile = unwrappedProjectFolder.path.appendingPathComponent(path: outputFileName)
            } else {
                projectFile = nil // TODO: check - we want three way comparison everytime
            }

//            if file.name == "Podfile" {
//                if validationMode {
//                    let validationFolder = try Folder(path: Paths.validationPath)
//                    try file.copy(to: validationFolder)
//                    processedFiles.append((
//                        templateFile: templateFile,
//                        generatedFile: validationFolder.path.appendingPathComponent(path: file.name),
//                        projectFile: Paths.projectPath.appendingPathComponent(path: file.name)
//                    ))
//                } else {
//                    let generatedFolder = try Folder(path: Paths.generatedPath)
//                    try file.copy(to: generatedFolder)
//                    processedFiles.append((
//                        templateFile: templateFile,
//                        generatedFile: generatedFolder.path.appendingPathComponent(path: file.name),
//                        projectFile: Paths.projectPath.appendingPathComponent(path: file.name)
//                    ))
//                }
//
//                continue
//            }

            // Directly copy binary file
            guard let _ = try? file.readAsString() else {
                let copiedFile = try file.copy(to: generatedFolder)
                try copiedFile.rename(to: outputFileName)
                continue
            }

            let outputFile = try generatedFolder.createFile(named: outputFileName)

            var rendered: String
            do {
                rendered = try environment.renderTemplate(name: file.name, context: modifiedContext)
            } catch {
                throw ScriptError.generalError(message: "Stencil template error \(templateFolder.path): \(file.name): \(error.localizedDescription)")
            }

            try outputFile.write(rendered)

            processedFiles.append((templateFile: templateFile, generatedFile: generatedFile, projectFile: projectFile))
        }

        // Process subfolders
        for folder in templateFolder.subfolders {
            var baseGeneratedPath: String
            var baseProjectPath: String

            switch folder.name {
            case "_project":
                try traverse(
                    templateFolder: folder,
                    generatedFolder: try Folder(path: outputPath),
                    projectFolder: try Folder(path: Paths.projectPath),
                    context: context
                )

            case "_sources":
                if validationMode {
                    baseGeneratedPath = outputPath
                } else {
                    baseGeneratedPath = try generatedFolder.createSubfolder(at: Paths.sourcesPath.lastPathComponent).path
                }

                baseProjectPath = Paths.sourcesPath

                try traverse(
                    templateFolder: folder,
                    generatedFolder: try Folder(path: baseGeneratedPath),
                    projectFolder: try Folder(path: baseProjectPath),
                    context: context
                )

            case "_location":
                let subPath = String(Paths.locationPath.suffix(Paths.locationPath.count - Paths.projectPath.count))

                if validationMode {
                    baseGeneratedPath = outputPath
                } else {
                    baseGeneratedPath = try generatedFolder.createSubfolder(at: subPath).path
                }

                baseProjectPath = Paths.locationPath

                try traverse(
                    templateFolder: folder,
                    generatedFolder: try Folder(path: baseGeneratedPath),
                    projectFolder: try Folder(path: baseProjectPath),
                    context: context
                )

            default:
                let outputFolder = folder.name.modifyName(context: context)
                let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)

                let projectSubFolder: Folder?
                if let unwrappedProjectFolder = projectFolder {
                    projectSubFolder = try? Folder(path: unwrappedProjectFolder.path.appendingPathComponent(path: outputFolder))
                } else {
                    projectSubFolder = nil
                }

                try traverse(templateFolder: folder, generatedFolder: generatedSubFolder, projectFolder: projectSubFolder,context: context)
            }
        }
    }
}
