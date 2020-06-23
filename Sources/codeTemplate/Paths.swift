//
//  Constants.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation
import ScriptToolkit

class Paths {
    static var scriptPath: String = ""
    static var templatePath: String = ""
    static var generatedPath: String = ""

    static var projectPath: String = ""
    static var scenePath: String = ""

    static func setupPaths(context: Context) throws {
        if let unwrappedProjectPath = context["projectPath"] as? String {
            Paths.projectPath = unwrappedProjectPath
        } else {
            throw ScriptError.moreInfoNeeded(message: "projectPath is missing")
        }

        if let unwrappedScenePath = context["scenePath"] as? String {
            // If path is absolute
            if unwrappedScenePath.starts(with: "/") {
                Paths.scenePath = unwrappedScenePath
            } else {
                Paths.scenePath = Paths.projectPath.appendingPathComponent(path: unwrappedScenePath)
            }
        } else {
            throw ScriptError.moreInfoNeeded(message: "scenePath is missing")
        }

        if let unwrappedScriptPath = context["scriptPath"] as? String {
            Paths.scriptPath = unwrappedScriptPath
            Paths.templatePath = Paths.scriptPath.appendingPathComponent(path: "Templates")
            Paths.generatedPath = Paths.scriptPath.appendingPathComponent(path: "Generated")
        } else {
            throw ScriptError.moreInfoNeeded(message: "scriptPath is missing")
        }
    }
}
