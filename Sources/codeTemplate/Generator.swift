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

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }()

    func generate(
        generationMode: GenerationMode,
        context: Context,
        reviewMode: ReviewMode = .none,
        deleteGenerated: Bool = true
    ) throws {
        switch generationMode {
        case let .template(templateType):

            // Delete contents of Generated folder
            let generatedFolder = try Folder(path: Paths.generatedPath)
            if deleteGenerated {
                try generatedFolder.empty(includingHidden: true)
            }

            let templateFolder = try Folder(path: Paths.templatePath).subfolder(at: templateType.rawValue)

            let projectFolder = try Folder(path: templateType.basePath())

            try traverse(templateFolder: templateFolder, generatedFolder: generatedFolder, projectFolder: projectFolder, context: context)

        case let .combo(comboType):
            try comboType.perform(context: context)
        }

        shell("/usr/local/bin/swiftformat \"\(Paths.scriptPath)\"")

        try Reviewer.shared.review(mode: reviewMode, processedFiles: processedFiles)
    }

    func updateContext(_ context: Context) -> Context {
        var modifiedContext = context
        for key in context.keys {
            guard let stringValue = context[key] as? String else { continue }
            modifiedContext[key.pascalCased()] = stringValue.pascalCased()
        }

        modifiedContext["date"] = dateFormatter.string(from: Date())

        if let unwrappedOldTableViewCells = context["oldTableViewCells"] as? [String], let unwrappedNewTableViewCells = context["newTableViewCells"] as? [String] {
            modifiedContext["tableViewCells"] = unwrappedOldTableViewCells + unwrappedNewTableViewCells
        }

        if let unwrappedOldCollectionViewCells = context["oldCollectionViewCells"] as? [String], let unwrappedNewCollectionViewCells = context["newCollectionViewCells"] as? [String] {
            modifiedContext["collectionViewCells"] = unwrappedOldCollectionViewCells + unwrappedNewCollectionViewCells
        }

        modifiedContext["Screen"] = modifiedContext["Name"]

        return modifiedContext
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

    func traverse(templateFolder: Folder, generatedFolder: Folder, projectFolder: Folder?, context: Context) throws {
        var modifiedContext = context

        let environment = stencilEnvironment(templateFolder: templateFolder)

        // Process files in folder
        for file in templateFolder.files {
            let outputFileName = file.name.modifyName(context: context)
            modifiedContext["fileName"] = outputFileName
            let outputFile = try generatedFolder.createFile(named: outputFileName)

            let rendered = try environment.renderTemplate(name: file.name, context: modifiedContext)

            try outputFile.write(rendered)

            let templateFile = templateFolder.path + "/" + file.name
            let generatedFile = generatedFolder.path + "/" + outputFileName

            let projectFile: String?
            if let unwrappedProjectFolder = projectFolder {
                projectFile = unwrappedProjectFolder.path + "/" + outputFileName
            } else {
                projectFile = nil
            }

            processedFiles.append((templateFile: templateFile, generatedFile: generatedFile, projectFile: projectFile))
        }

        // Process subfolders
        for folder in templateFolder.subfolders {
            let outputFolder = folder.name.modifyName(context: context)
            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)

            let projectSubFolder: Folder?
            if let unwrappedProjectFolder = projectFolder {
                projectSubFolder = try? Folder(path: unwrappedProjectFolder.path + "/" + outputFolder)
            } else {
                projectSubFolder = nil
            }

            try traverse(templateFolder: folder, generatedFolder: generatedSubFolder, projectFolder: projectSubFolder,context: context)
        }
    }
}
