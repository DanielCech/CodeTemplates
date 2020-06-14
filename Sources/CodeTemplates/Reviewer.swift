//
//  Reviewer.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 14/06/2020.
//

import Foundation
import Stencil
import PathKit
import Files
import ScriptToolkit

class Reviewer {
    static let shared = Reviewer()
    
    func review(mode: ReviewMode, context: Context) throws {
        switch mode {
        case .overall:
            let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + generatedPath + "\" \"" + targetPath + "\""
            shell(command)
            
        case .individual:
//            try traverse(templateFolder: templateFolder, generatedFolder: generatedFolder, context: context)
            
            let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" -3 \"/Users/danielcech/Documents/[Development]/[Projects]/CodeTemplates/Templates/viewControllerRxSwiftWithTableView/{{Name}}ViewController.swift.stencil\" \"/Users/danielcech/Documents/[Development]/[Projects]/CodeTemplates/Generated/EmergencyContactsViewController.swift\" \"/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS/Harbor/Scenes/HouseholdScene/EmergencyContacts/EmergencyContactsViewController.swift\""
            shell(command)
        }
    }
}

private extension Reviewer {
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

