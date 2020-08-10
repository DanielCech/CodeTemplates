//
//  Constants.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation
import ScriptToolkit

class Paths {
    // CodeTemplates paths
    static var scriptPath: String = "" // codeTemplate
    static var templatePath: String = "" // codeTemplate/Templates
    static var generatePath: String = "" // codeTemplate/Generate
    static var validatePath: String = "" // codeTemplate/Validate
    static var preparePath: String = "" // codeTemplate/Prepare

    // Project paths
    static var projectPath: String = "" // harbor-ios
    static var sourcesPath: String = "" // harbor-ios/Harbor
    static var locationPath: String = "" // harbor-ios/Harbor/...

    /// Setup paths from context
    static func setupPaths() throws {
        if let unwrappedProjectPath = MainContext.optionalStringValue(.projectPath) {
            Paths.projectPath = unwrappedProjectPath
        } else {
            throw ScriptError.moreInfoNeeded(message: "projectPath is missing")
        }

        if let unwrappedSourcesPath = MainContext.optionalStringValue(.sourcesPath) {
            Paths.sourcesPath = unwrappedSourcesPath
        } else {
            // Derive sources path from project path and project name
            if let unwrappedProjectName = MainContext.optionalStringValue(.projectName) {
                Paths.sourcesPath = Paths.projectPath.appendingPathComponent(path: unwrappedProjectName)
            } else {
                throw ScriptError.moreInfoNeeded(message: "unknown sourcesPath")
            }
        }

        if let unwrappedLocationPath = MainContext.optionalStringValue(.locationPath) {
            // If path is absolute
            if unwrappedLocationPath.starts(with: "/") {
                Paths.locationPath = unwrappedLocationPath
            } else {
                Paths.locationPath = Paths.projectPath.appendingPathComponent(path: unwrappedLocationPath)
            }
        } else {
            // TODO: check - location path is not sometimes needed
            throw ScriptError.moreInfoNeeded(message: "locationPath is missing")
        }

        if let unwrappedScriptPath = MainContext.optionalStringValue(.scriptPath) {
            Paths.scriptPath = unwrappedScriptPath
            Paths.templatePath = Paths.scriptPath.appendingPathComponent(path: "Templates")
            Paths.generatePath = Paths.scriptPath.appendingPathComponent(path: "Generate")
            Paths.validatePath = Paths.scriptPath.appendingPathComponent(path: "Validate")
            Paths.preparePath = Paths.scriptPath.appendingPathComponent(path: "Prepare")
        } else {
            throw ScriptError.moreInfoNeeded(message: "scriptPath is missing")
        }
    }
}
