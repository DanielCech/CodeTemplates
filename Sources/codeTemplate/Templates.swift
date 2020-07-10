//
//  Template.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import ScriptToolkit

public typealias Template = String

/// Code template management
class Templates {
    static let shared = Templates()

    /// Internal representation of templates
    private var templateTypesDict: [Template: TemplateInfo] = [:]
    
    /// Internal representation of template dependencies
    private var templateDependenciesDict: [Template: [Template]] = [:]

    /// Loads templates from folder structure in Templates dir and loads their json
    func templateTypes() throws -> [Template: TemplateInfo] {
        if !templateTypesDict.isEmpty {
            return templateTypesDict
        }

        print("💡 Loading templates")

        var types = [Template: TemplateInfo]()

        let templatesFolder = try Folder(path: Paths.templatePath)

        for categoryFolder in templatesFolder.subfolders {
            if categoryFolder.name == "_combos" {
                continue
            }

            for templateFolder in categoryFolder.subfolders {
                let infoFilePath = templateFolder.path.appendingPathComponent(path: "template.json")
                guard FileManager.default.fileExists(atPath: infoFilePath) else {
                    throw ScriptError.fileNotFound(message: infoFilePath)
                }

                let info = try templateInfo(infoFilePath: infoFilePath, category: categoryFolder.name)

                types[templateFolder.name] = info

                // TemplateInfo(category: categoryFolder.name, templateInfo: templateInfo)
            }
        }

        templateTypesDict = types

        return types
    }

    /// Loads template dependencies from json
    func templateDependencies() throws -> [Template: [Template]] {
        if !templateDependenciesDict.isEmpty {
            return templateDependenciesDict
        }

        let dependenciesFilePath = Paths.templatePath.appendingPathComponent(path: "dependencies.json")

        let dependenciesFile = try File(path: dependenciesFilePath)
        let dependenciesString = try dependenciesFile.readAsString(encodedAs: .utf8)
        let dependenciesData = Data(dependenciesString.utf8)

        // make sure this JSON is in the format we expect
        guard let dependencies = try JSONSerialization.jsonObject(with: dependenciesData, options: []) as? [Template: [Template]] else {
            throw ScriptError.generalError(message: "Deserialization error")
        }

        templateDependenciesDict = dependencies

        return dependencies
    }

    /// Returns template category
    func templateCategory(for template: Template) throws -> String {
        if let templateInfo = try templateTypes()[template] {
            return templateInfo.category
        } else {
            throw ScriptError.argumentError(message: "template does not exist")
        }
    }

    /// Returns template info structure
    func templateInfo(for template: Template) throws -> TemplateInfo {
        if let templateInfo = try templateTypes()[template] {
            return templateInfo
        } else {
            throw ScriptError.argumentError(message: "template does not exist")
        }
    }

    /// Creates template info structure from json
    private func templateInfo(infoFilePath: String, category: String) throws -> TemplateInfo {
        let templateInfoFile = try File(path: infoFilePath)
        let templateInfoString = try templateInfoFile.readAsString(encodedAs: .utf8)
        let templateInfoData = Data(templateInfoString.utf8)

        // make sure this JSON is in the format we expect
        guard let info = try JSONSerialization.jsonObject(with: templateInfoData, options: []) as? [String: Any] else {
            throw ScriptError.generalError(message: "Deserialization error")
        }

        let templateInfo = TemplateInfo(
            category: category,
            completeness: (info["completeness"] as? Int) ?? 0,
            compilable: (info["compilable"] as? Bool) ?? true,
            context: (info["context"] as? Context) ?? [:],
            switches: (info["switches"] as? [Template]) ?? []
        )

        return templateInfo
    }
}
