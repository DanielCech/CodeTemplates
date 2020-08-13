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

/// Power operator - used for counting the possible combinations
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

/// Validation the templates - test whether they can be compiled separately with all possible combinations of switches
public class Validator {
    public static let shared = Validator()

    /// Validate all templates
    func validateTemplates() throws {
        for template in try Templates.shared.templateTypes().keys {
            try validate(template: template)
        }
    }

    /// Validate particular template
    func validate(template: Template, context: Context = mainContext) throws {
        print("🔎 \(template)")

        // Empty validation folder
        let validationFolder = try Folder(path: context.stringValue(.validatePath))
        try validationFolder.empty(includingHidden: true)

        // Load template settings
        let context = defaultContext()
        let templateInfo = try Templates.shared.templateInfo(for: template)

        if templateInfo.compilable == false {
            print("ℹ️ template \(template) is marked as non-compilable. Skipping.")
            return
        }

        print("✂️ template \(template):")

        // Update default context with settings context
        for key in templateInfo.context.dictionary.keys {
            context.dictionary[key] = templateInfo.context.dictionary[key]
        }

        // Series of switches values - all combinations
        for index in 0 ..< 2 ^^ templateInfo.switches.count {
            let unsignedIndex = UInt32(index)

            for (switchIndex, switchElement) in templateInfo.switches.enumerated() {
                let unsignedSwitchBit: UInt32 = 1 << switchIndex
                if (unsignedIndex & unsignedSwitchBit) > 0 {
                    context.dictionary[switchElement] = true
                    print("    \(switchElement): true")
                } else {
                    context.dictionary[switchElement] = false
                    print("    \(switchElement): false")
                }
            }

            if !templateInfo.switches.isEmpty {
                print("    --------------------------")
            }

            try checkTemplateCombination(template: template, context: context)
        }
    }
}

private extension Validator {
    /// Check particular template combination of enabled switches
    func checkTemplateCombination(template: Template, context: Context) throws {
        let validationFolder = try Folder(path: context.stringValue(.validatePath))

        let modifiedContext = Context(fromContext: context)
        modifiedContext[.generatePath] = modifiedContext[.validatePath]

        try Generator.shared.generate(
            context: modifiedContext,
            generationMode: .template("SingleViewApp"),
            deleteGenerate: true
        )

        let outputFolder = try validationFolder.subfolder(named: "Template")

        try Generator.shared.generate(
            context: modifiedContext,
            generationMode: .template(template),
            deleteGenerate: false,
            validationMode: true
        )

        print("    🗳 generating xcode project")
        // Create Xcodeproj
        let xcodegenOutput = shell("cd \"\(validationFolder.path)\";/usr/local/bin/xcodegen generate > /dev/null 2>&1")
        if xcodegenOutput.contains("error") {
            print(xcodegenOutput)
        }

        // Instal Cocoapods if needed
        if outputFolder.containsFile(named: "Podfile") {
            print("    📦 installing pods")

            let podfile = try outputFolder.file(named: "Podfile")
            try podfile.move(to: validationFolder)

            let podsOutput = shell("cd \"\(validationFolder.path)\";export LANG=en_US.UTF-8;/usr/local/bin/pod install")
            if podsOutput.lowercased().contains("error") {
                print(podsOutput)
            }

            print("    🕓 building workspace")
            // Build workspace
            let xcodebuildOutput = shell("/usr/bin/xcodebuild -workspace \(validationFolder.path)/Template.xcworkspace/ -scheme Template -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.5' build 2>&1")
            if xcodebuildOutput.contains("BUILD FAILED") {
                print(xcodebuildOutput)
            }
        } else {
            print("    🕓 building project")

            // Build project
            let xcodebuildOutput = shell("/usr/bin/xcodebuild -project \(validationFolder.path)/Template.xcodeproj/ -scheme Template build 2>&1")
            if xcodebuildOutput.contains("BUILD FAILED") {
                print(xcodebuildOutput)
            }
        }

        print("    🟢 Press enter to continue...", terminator: "")
        _ = readLine()
    }

    /// Default context used for template validation
    func defaultContext() -> Context {
        let context = Context(
            dictionary: [
                "scriptPath": "/Users/danielcech/Documents/[Development]/[Projects]/codeTemplate",

                "name": "test",
                "Name": "Test",

                "author": "Daniel Cech",
                "projectName": "Template",
                "copyright": "Copyright © 2020 STRV. All rights reserved.",

                "fakeNavbar": false,
                "sectionHeaders": false,

                "newTableViewCells": ["textField"],
                "tableContentFromAPI": false,

                "whiteCellSelection": true
            ]
        )

        ContextProvider.updateContext(context)
        try? Paths.setupScriptPaths(context: context)

        return context
    }
}
