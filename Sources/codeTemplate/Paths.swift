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
    static var generatedPath: String = "" // codeTemplate/Generated
    static var validationPath: String = "" // codeTemplate/Validation

    // Project paths
    static var projectPath: String = "" // harbor-ios
    static var sourcesPath: String = "" // harbor-ios/Harbor
    static var locationPath: String = "" // harbor-ios/Harbor/...

    static func setupPaths(context: Context) throws {
        if let unwrappedProjectPath = context["projectPath"] as? String {
            Paths.projectPath = unwrappedProjectPath
        } else {
            throw ScriptError.moreInfoNeeded(message: "projectPath is missing")
        }

        if let unwrappedSourcesPath = context["sourcesPath"] as? String {
            Paths.sourcesPath = unwrappedSourcesPath
        } else {
            // Derive sources path from project path and project name
            if let unwrappedProjectName = context["projectName"] as? String {
                Paths.sourcesPath = Paths.projectPath.appendingPathComponent(path: unwrappedProjectName)
            } else {
                throw ScriptError.moreInfoNeeded(message: "unknown sourcesPath")
            }
        }

        if let unwrappedScenePath = context["locationPath"] as? String {
            // If path is absolute
            if unwrappedScenePath.starts(with: "/") {
                Paths.locationPath = unwrappedScenePath
            } else {
                Paths.locationPath = Paths.projectPath.appendingPathComponent(path: unwrappedScenePath)
            }
        } else {
            throw ScriptError.moreInfoNeeded(message: "locationPath is missing")
        }

        if let unwrappedScriptPath = context["scriptPath"] as? String {
            Paths.scriptPath = unwrappedScriptPath
            Paths.templatePath = Paths.scriptPath.appendingPathComponent(path: "Templates")
            Paths.generatedPath = Paths.scriptPath.appendingPathComponent(path: "Generated")
            Paths.validationPath = Paths.scriptPath.appendingPathComponent(path: "Validation")
        } else {
            throw ScriptError.moreInfoNeeded(message: "scriptPath is missing")
        }
    }
}
