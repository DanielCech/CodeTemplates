//
//  Preparator.swift
//  codeTemplate
//
//  Created by Daniel Cech on 17/07/2020.
//

import Foundation
import Files
import ScriptToolkit

class Preparator {
    public static let shared = Preparator()
    
    func prepareTemplate(context: Context) throws {
        guard let template = context["template"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "template")
        }
        
        guard let category = context["category"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "category")
        }
        
        guard let projectFiles = context["projectFiles"] as? [String] else {
            throw CodeTemplateError.parameterNotSpecified(message: "projectFiles")
        }
        
        guard let name = context["name"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "name")
        }
        
        try Paths.setupPaths(context: context)
        
        for projectFile in projectFiles {
            try prepareTemplate(
                forFile: projectFile,
                template: template,
                category: category,
                name: name,
                context: context)
        }
    }
    
    func prepareTemplate(
        forFile projectFile: String,
        template: Template,
        category: String,
        name: String,
        context: Context
    ) throws {
        // Create template folder
        let templatePath = Paths.templatePath.appendingPathComponent(path: category).appendingPathComponent(path: template)
        try? FileManager.default.createDirectory(atPath: templatePath, withIntermediateDirectories: true, attributes: nil)
        
        let inputFile = try File(path: projectFile)
        
        // Prepare target folder structure
        var templateDestination: TemplateDestination
        var projectSubPath = projectFile.deletingLastPathComponent.withoutSlash()
        
        if projectFile.deletingLastPathComponent.lowercased().withoutSlash() == Paths.projectPath.lowercased().withoutSlash() {
            templateDestination = .project
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - Paths.projectPath.count))
        }
        else if projectFile.lowercased().withoutSlash().starts(with: Paths.locationPath.lowercased().withoutSlash()) {
            templateDestination = .location
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - Paths.locationPath.count))
        }
        else if projectFile.lowercased().withoutSlash().starts(with: Paths.sourcesPath.lowercased().withoutSlash()) {
            templateDestination = .sources
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - Paths.sourcesPath.count))
        }
        else {
            throw CodeTemplateError.invalidProjectFilePath(message: projectFile)
        }
    
        let templateSubPath = Paths.templatePath.appendingPathComponent(path: templateDestination.rawValue)
        try? FileManager.default.createDirectory(atPath: templateSubPath, withIntermediateDirectories: true, attributes: nil)
        
        let templateDestinationPath = templateSubPath.appendingPathComponent(path: projectSubPath)
        try? FileManager.default.createDirectory(atPath: templateDestinationPath, withIntermediateDirectories: true, attributes: nil)
        
        let templateDestinationFolder = try Folder(path: templateDestinationPath)
        let copiedFile = try inputFile.copy(to: templateDestinationFolder)
        
//        let copiedFile = try file.copy(to: generatedFolder)
//        try copiedFile.rename(to: outputFileName)
//            continue
//        }
    }
    
}
