//
//  Constants.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation
import ScriptToolkit

class Paths {
    /// Setup paths for project
    static func setupProjectPaths(context: Context = mainContext) throws {
        guard let unwrappedProjectPath = context.optionalStringValue(.projectPath) else {
            throw ScriptError.moreInfoNeeded(message: "projectPath is missing")
        }

        if context.optionalStringValue(.sourcesPath) == nil {
            // Derive sources path from project path and project name
            if let unwrappedProjectName = context.optionalStringValue(.projectName) {
                context[.sourcesPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedProjectName)
            } else {
                throw ScriptError.moreInfoNeeded(message: "unknown sourcesPath")
            }
        }

        if let unwrappedLocationPath = context.optionalStringValue(.locationPath) {
            // If path is absolute
            if unwrappedLocationPath.starts(with: "/") {
                context[.locationPath] = unwrappedLocationPath
            } else {
                context[.locationPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedLocationPath)
            }
        } else {
            // TODO: check - location path is not sometimes needed
            throw ScriptError.moreInfoNeeded(message: "locationPath is missing")
        }
    }

    /// Setup paths for script
    static func setupScriptPaths(context: Context = mainContext) throws {
        if let unwrappedScriptPath = context.optionalStringValue(.scriptPath) {
            context[.templatePath] = unwrappedScriptPath.appendingPathComponent(path: "Templates")
            context[.generatePath] = unwrappedScriptPath.appendingPathComponent(path: "Generate")
            context[.validatePath] = unwrappedScriptPath.appendingPathComponent(path: "Validate")
            context[.preparePath] = unwrappedScriptPath.appendingPathComponent(path: "Prepare")
        } else {
            throw ScriptError.moreInfoNeeded(message: "scriptPath is missing")
        }
    }
}
