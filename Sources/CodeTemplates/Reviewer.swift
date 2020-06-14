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

func compareTwoItems(first: String, second: String) {
    let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + generatedPath + "\" \"" + projectPath + "\""
    shell(command)
}

func compareThreeItems(first: String, second: String, third: String) {
    let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" -3 \""
        + first + "\" \""
        + second + "\" \""
        + third + "\""
    shell(command)
    shell(command)
}

class Reviewer {
    static let shared = Reviewer()
    
    func review(mode: ReviewMode, processedFiles: [ProcessedFile]) throws {
        switch mode {
        case .none:
            break
            
        case .overall:
            compareTwoItems(first: generatedPath, second: projectPath)
            
        case .individual:
            for processedFile in processedFiles {
                if let unwrappedProjectFile = processedFile.projectFile {
                    compareThreeItems(first: processedFile.templateFile, second: processedFile.generatedFile, third: unwrappedProjectFile)
                }
                else {
                    compareTwoItems(first: processedFile.templateFile, second: processedFile.generatedFile)
                }
                
                print(processedFile.generatedFile.lastPathComponent + ":")
                print("🟢 Press any key to continue...")
                _ = readLine()
            }
        }
    }
}

//private extension Reviewer {
//    func traverse(templateFolder: Folder, generatedFolder: Folder, projectFolder: Folder, context: Context) throws {
//        var modifiedContext = context
//        
//        // Process files in folder
//        for file in templateFolder.files {
//            let environment = Environment(loader: FileSystemLoader(paths: [Path(templateFolder.path)]))
//            
//            let outputFileName = file.name.modifyName(context: context)
//            modifiedContext["fileName"] = outputFileName
//            let outputFile = try generatedFolder.createFile(named: outputFileName)
//            
//            let rendered = try environment.renderTemplate(name: file.name, context: modifiedContext)
//        
//            try outputFile.write(rendered)
//        }
//        
//        // Process subfolders
//        for folder in templateFolder.subfolders {
//            let outputFolder = folder.name.modifyName(context: context)
//            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)
//            try traverse(templateFolder: folder, generatedFolder: generatedSubFolder, projectFolcontext: context)
//        }
//    }
//}

