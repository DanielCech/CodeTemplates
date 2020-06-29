//
//  Validator.swift
//  codeTemplate
//
//  Created by Daniel Cech on 27/06/2020.
//

import Foundation

import Files
import Foundation
import ScriptToolkit

// Power operator
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

public class Validator {
    public static let shared = Validator()
    
    public func validateTemplates(scriptPath: String) throws {
        for template in TemplateType.allCases {
            print("🔎 \(template.rawValue)")
            try validate(template: template, scriptPath: scriptPath)
        }
    }

    public func validate(template: TemplateType, scriptPath: String) throws {
        Paths.scriptPath = scriptPath
        Paths.templatePath = Paths.scriptPath.appendingPathComponent(path: "Templates")
        Paths.validationPath = Paths.scriptPath.appendingPathComponent(path: "Validation")
        
        // Empty validation folder
        let validationFolder = try Folder(path: Paths.validationPath)
        try validationFolder.empty(includingHidden: true)
        
        // Load template settings
        var context = defaultContext()
        let settings = try templateSettings(template: template)
        
        guard
            let settingsContext = settings["context"] as? Context,
            let settingsSwitches = settings["switches"] as? [String]
        else {
                throw ScriptError.generalError(message: "template.json data corrupted")
        }
        
        // Update default context with settings context
        for key in settingsContext.keys {
            context[key] = settingsContext[key]
        }
        
        // Series of switches values - all combinations
        for index in 0 ..< 2^^settingsSwitches.count {
            let unsignedIndex = UInt32(index)
            
            for (switchIndex, switchElement) in settingsSwitches.enumerated() {
                let unsignedSwitchBit: UInt32 = 1 << switchIndex
                if (unsignedIndex & unsignedSwitchBit) > 0 {
                    context[switchElement] = true
                    print("    \(switchElement): true")
                }
                else {
                    context[switchElement] = false
                    print("    \(switchElement): false")
                }
            }
            
            if !settingsSwitches.isEmpty {
                print("    --------------------------")
            }
            
            
            
            
        }
        
        
//        try Generator.shared.generate(
//            generationMode: .template(template),
//            context: context,
//            reviewMode: .none,
//            deleteGenerated: true,
//            outputPath: Paths.generatedPath.appendingPathComponent(path: template.rawValue)
//        )
        
        
    }
}

private extension Validator {
    func templateSettings(template: TemplateType) throws -> Settings {
        let settingFilePath = Paths.templatePath
            .appendingPathComponent(path: template.category.rawValue)
            .appendingPathComponent(path: template.rawValue)
            .appendingPathComponent(path: "template.json")

        let settingFile = try File(path: settingFilePath)
        let settingsString = try settingFile.readAsString(encodedAs: .utf8)
        let settingsData = Data(settingsString.utf8)

        // make sure this JSON is in the format we expect
        guard let settings = try JSONSerialization.jsonObject(with: settingsData, options: []) as? [String: Any] else {
            throw ScriptError.generalError(message: "Deserialization error")
        }
        
        return settings
    }
    
    func defaultContext() -> Context {
        return [:]
    }
}
