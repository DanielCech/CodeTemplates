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
    static func setupProjectPaths(context: Context = mainContext) throws -> Context {
        var modifiedContext = context

        guard let unwrappedProjectPath = modifiedContext.optionalStringValue(.projectPath) else {
            throw ScriptError.moreInfoNeeded(message: "projectPath is missing")
        }

        if modifiedContext.optionalStringValue(.sourcesPath) == nil {
            // Derive sources path from project path and project name
            if let unwrappedProjectName = modifiedContext.optionalStringValue(.projectName) {
                modifiedContext[.sourcesPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedProjectName)
            } else {
                throw ScriptError.moreInfoNeeded(message: "unknown sourcesPath")
            }
        }

        if let unwrappedLocationPath = modifiedContext.optionalStringValue(.locationPath) {
            // If path is absolute
            if unwrappedLocationPath.starts(with: "/") {
                modifiedContext[.locationPath] = unwrappedLocationPath
            } else {
                modifiedContext[.locationPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedLocationPath)
            }
        } else {
            // TODO: check - location path is not sometimes needed
            throw ScriptError.moreInfoNeeded(message: "locationPath is missing")
        }

        return modifiedContext
    }

    /// Setup paths for script
    static func setupScriptPaths(context: Context = mainContext) throws -> Context {
        var modifiedContext = context

        if let unwrappedScriptPath = mainContext.optionalStringValue(.scriptPath) {
            modifiedContext[.templatePath] = unwrappedScriptPath.appendingPathComponent(path: "Templates")
            modifiedContext[.generatePath] = unwrappedScriptPath.appendingPathComponent(path: "Generate")
            modifiedContext[.validatePath] = unwrappedScriptPath.appendingPathComponent(path: "Validate")
            modifiedContext[.preparePath] = unwrappedScriptPath.appendingPathComponent(path: "Prepare")
        } else {
            throw ScriptError.moreInfoNeeded(message: "scriptPath is missing")
        }

        return modifiedContext
    }
}
