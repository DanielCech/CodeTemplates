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

func capitalizeContext(_ context: Context) -> Context {
    var modifiedContext = context
    for key in context.keys {
        guard let stringValue = context[key] as? String else { continue }
        modifiedContext[key.capitalizingFirstLetter()] = stringValue.capitalizingFirstLetter()
    }
    
    return modifiedContext
}

func modifyName(_ name: String, context: Context) -> String {
    var newName = name.replacingOccurrences(of: ".stencil", with: "")
    for key in context.keys {
        guard let stringValue = context[key] as? String else { continue }
        newName = newName.replacingOccurrences(of: "{{\(key)}}", with: stringValue)
    }
    return newName
}

func traverse(templateFolder: Folder, generatedFolder: Folder, context: Context) throws {
    
    // Process files in folder
    for file in templateFolder.files {
        let environment = Environment(loader: FileSystemLoader(paths: [Path(templateFolder.path)]))
        let rendered = try environment.renderTemplate(name: file.name, context: context)
        
        let outputFileName = modifyName(file.name, context: context)
        let outputFile = try generatedFolder.createFile(named: outputFileName)
        try outputFile.write(rendered)
    }
    
    // Process subfolders
    for folder in templateFolder.subfolders {
        let outputFolder = modifyName(folder.name, context: context)
        let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)
        try traverse(templateFolder: folder, generatedFolder: generatedSubFolder, context: context)
    }
}

func generate(template: TemplateType, context: Context) throws {
    let modifiedContext = capitalizeContext(context)
    
    // Delete contents of Generated folder
    let generatedFolder = try Folder(path: generatedPath)
    try generatedFolder.empty(includingHidden: true)
    
    let templateFolder = try Folder(path: templatePath).subfolder(at: template.rawValue)
    
    try traverse(templateFolder: templateFolder, generatedFolder: generatedFolder, context: modifiedContext)
}
