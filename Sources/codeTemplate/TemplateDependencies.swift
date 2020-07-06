//
//  TemplateDependencies.swift
//  codeTemplate
//
//  Created by Daniel Cech on 06/07/2020.
//

import Foundation
import ScriptToolkit
import Files

class TemplateDependencies {
    static let shared = TemplateDependencies()
    
    private var templateDependenciesDict: [TemplateType: [TemplateType]] = [:]
    
    func templateDependencies() throws -> [TemplateType: [TemplateType]] {
        if !templateDependenciesDict.isEmpty {
            return templateDependenciesDict
        }
        
        let dependenciesFilePath = Paths.templatePath.appendingPathComponent(path: "dependencies.json")

        let dependenciesFile = try File(path: dependenciesFilePath)
        let dependenciesString = try dependenciesFile.readAsString(encodedAs: .utf8)
        let dependenciesData = Data(dependenciesString.utf8)

        // make sure this JSON is in the format we expect
        guard let dependencies = try JSONSerialization.jsonObject(with: dependenciesData, options: []) as? [TemplateType: [TemplateType]] else {
            throw ScriptError.generalError(message: "Deserialization error")
        }
        
        templateDependenciesDict = dependencies

        return dependencies
    }
    
}
