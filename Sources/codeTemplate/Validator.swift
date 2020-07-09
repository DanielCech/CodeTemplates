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
        for template in try Templates.shared.templateTypes().keys {
            try validate(template: template, scriptPath: scriptPath)
        }
    }

    public func validate(template: Template, scriptPath: String) throws {
        print("🔎 \(template)")

        Paths.scriptPath = scriptPath
        Paths.templatePath = Paths.scriptPath.appendingPathComponent(path: "Templates")
        Paths.validationPath = Paths.scriptPath.appendingPathComponent(path: "Validation")

        // Empty validation folder
        let validationFolder = try Folder(path: Paths.validationPath)
        try validationFolder.empty(includingHidden: true)

        // Load template settings
        var context = defaultContext()
        let templateInfo = try Templates.shared.templateInfo(for: template)

        // Update default context with settings context
        for key in templateInfo.context.keys {
            context[key] = templateInfo.context[key]
        }

        // Series of switches values - all combinations
        for index in 0 ..< 2 ^^ templateInfo.switches.count {
            let unsignedIndex = UInt32(index)

            for (switchIndex, switchElement) in templateInfo.switches.enumerated() {
                let unsignedSwitchBit: UInt32 = 1 << switchIndex
                if (unsignedIndex & unsignedSwitchBit) > 0 {
                    context[switchElement] = true
                    print("    \(switchElement): true")
                } else {
                    context[switchElement] = false
                    print("    \(switchElement): false")
                }
            }

            if !templateInfo.switches.isEmpty {
                print("    --------------------------")
            }

            let validationFolder = try Folder(path: Paths.validationPath)

            try Generator.shared.generate(
                generationMode: .template("singleViewApp"),
                context: context,
                reviewMode: .none,
                deleteGenerated: true,
                outputPath: validationFolder.path
            )

            let outputFolder = try validationFolder.subfolder(named: "Template")

            try Generator.shared.generate(
                generationMode: .template(template),
                context: context,
                reviewMode: .none,
                deleteGenerated: false,
                outputPath: outputFolder.path,
                validationMode: true
            )

            // Create Xcodeproj
            let xcodegenOutput = shell("cd \"\(validationFolder.path)\";/usr/local/bin/xcodegen generate > /dev/null 2>&1")
            if xcodegenOutput.contains("error") {
                print(xcodegenOutput)
            }

            // Instal Cocoapods if needed
            if validationFolder.containsFile(named: "Podfile") {
                let podsOutput = shell("cd \"\(validationFolder.path)\";export LANG=en_US.UTF-8;/usr/local/bin/pod install")
                if podsOutput.lowercased().contains("error") {
                    print(podsOutput)
                }

                // Build workspace
                let xcodebuildOutput = shell("/usr/bin/xcodebuild -workspace \(validationFolder.path)/Template.xcworkspace/ -scheme Template build 2>&1")
                if xcodebuildOutput.contains("BUILD FAILED") {
                    print(xcodebuildOutput)
                }
            } else {
                // Build project
                let xcodebuildOutput = shell("/usr/bin/xcodebuild -project \(validationFolder.path)/Template.xcodeproj/ -scheme Template build 2>&1")
                if xcodebuildOutput.contains("BUILD FAILED") {
                    print(xcodebuildOutput)
                }
            }

            print("    🟢 Press any key to continue...")
            _ = readLine()
        }
    }
}

private extension Validator {
    func defaultContext() -> Context {
        let context: Context = [
            "scriptPath": "/Users/danielcech/Documents/[Development]/[Projects]/codeTemplate",
            "projectPath": "/Users/danielcech/Documents/[Development]/[Projects]/harbor-iOS",
            "locationPath": "Scenes/HouseholdScene/EmergencyContacts/EditEmergencyContact",

            "name": "test",
            "Name": "Test",

            "author": "Daniel Cech",
            "projectName": "Test",
            "copyright": "Copyright © 2020 STRV. All rights reserved.",

            "fakeNavbar": false,
            "sectionHeaders": false,

            "newTableViewCells": ["textField"],
            "tableContentFromAPI": false,

            "whiteCellSelection": true
        ]

        return ContextHelper.shared.updateContext(context)
    }
}
