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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }()

    func generate(template: TemplateType, context: Context, deleteGenerated: Bool = true) throws {
        let modifiedContext = capitalizeContext(context)
        
        // Delete contents of Generated folder
        let generatedFolder = try Folder(path: generatedPath)
        if deleteGenerated {
            try generatedFolder.empty(includingHidden: true)
        }
        
        let templateFolder = try Folder(path: templatePath).subfolder(at: template.rawValue)
        
        try traverse(templateFolder: templateFolder, generatedFolder: generatedFolder, context: modifiedContext)
    }

    func generate(combo: TemplateCombo, context: Context) throws {
        try combo.perform(context: context)
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

    func traverse(templateFolder: Folder, generatedFolder: Folder, context: Context) throws {
        var modifiedContext = context
        
        // Process files in folder
        for file in templateFolder.files {
            let environment = Environment(loader: FileSystemLoader(paths: [Path(templateFolder.path)]))
            
            let outputFileName = file.name.modifyName(context: context)
            modifiedContext["fileName"] = outputFileName
            let outputFile = try generatedFolder.createFile(named: outputFileName)
            
            let rendered = try environment.renderTemplate(name: file.name, context: modifiedContext)
        
            try outputFile.write(rendered)
        }
        
        // Process subfolders
        for folder in templateFolder.subfolders {
            let outputFolder = folder.name.modifyName(context: context)
            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)
            try traverse(templateFolder: folder, generatedFolder: generatedSubFolder, context: context)
        }
    }
}


