//
//  Generator.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation
import Stencil
import PathKit
import Files

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
            
            let modifiedContext = capitalizeContext(context)
            
            // Delete contents of Generated folder
            let generatedFolder = try Folder(path: generatedPath)
            if deleteGenerated {
                try generatedFolder.empty(includingHidden: true)
            }
            
            let templateFolder = try Folder(path: templatePath).subfolder(at: templateType.rawValue)
            
            let projectFolder = try Folder(path: projectPath)
            
            try traverse(templateFolder: templateFolder, generatedFolder: generatedFolder, projectFolder: projectFolder, context: modifiedContext)
            
        case let .combo(comboType):
            try comboType.perform(context: context)
        }
        
        try Reviewer.shared.review(mode: reviewMode, processedFiles: processedFiles)
    }
}

private extension Generator {
    func capitalizeContext(_ context: Context) -> Context {
        var modifiedContext = context
        for key in context.keys {
            guard let stringValue = context[key] as? String else { continue }
            modifiedContext[key.capitalizingFirstLetter()] = stringValue.capitalizingFirstLetter()
        }
        
        modifiedContext["date"] = dateFormatter.string(from: Date())
        
        return modifiedContext
    }

    func traverse(templateFolder: Folder, generatedFolder: Folder, projectFolder: Folder?, context: Context) throws {
        var modifiedContext = context
        
        // Process files in folder
        for file in templateFolder.files {
            let environment = Environment(loader: FileSystemLoader(paths: [Path(templateFolder.path)]))
            
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
            }
            else {
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
            }
            else {
                projectSubFolder = nil
            }
            
            try traverse(templateFolder: folder, generatedFolder: generatedSubFolder, projectFolder: projectSubFolder,context: context)
        }
    }
}


