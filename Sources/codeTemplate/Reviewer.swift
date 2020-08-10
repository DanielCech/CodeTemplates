//
//  Reviewer.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 14/06/2020.
//

import Files
import Foundation
import PathKit
import ScriptToolkit
import Stencil

/// Two-way file comparison
func compareTwoItems(first: String, second: String) {
    let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + first + "\" \"" + second + "\""
    shell(command)
}

/// Thre-way file comparison
func compareThreeItems(first: String, second: String, third: String) {
    let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" -3 \""
        + first + "\" \""
        + second + "\" \""
        + third + "\""
    shell(command)
}

/// Set date of modification to current moment
func touch(file: String) {
    let command = "touch \"" + file + "\""
    shell(command)
}

class Reviewer {
    static let shared = Reviewer()

    /// Review generated files - in one of two modes - overall or individual (each file separately)
    func review(mode: ReviewMode, processedFiles: [ProcessedFile]) throws {
        switch mode {
        case .none:
            break

        case .overall:
            compareTwoItems(first: mainContext.stringValue(.generatePath), second: mainContext.stringValue(.locationPath))

        case .individual:
            for processedFile in processedFiles {
                if try sameContents(processedFile) {
                    print("🧷 " + processedFile.generatedFile.lastPathComponent + ": same content, skipping\n")
                    continue
                }

                compareThreeItems(first: processedFile.templateFile, second: processedFile.generatedFile, third: processedFile.projectFile)

                print("🧷 " + processedFile.generatedFile.lastPathComponent + ":")

                // Check whether project folder exists
                let projectDestinationPath = processedFile.projectFile.deletingLastPathComponent
                if !FileManager.default.directoryExists(atPath: projectDestinationPath) {
                    print("    🟢 Project subfolder does not exist. Create? [yN] ", terminator: "")
                    if readLine() == "y" {
                        try FileManager.default.createDirectory(atPath: projectDestinationPath, withIntermediateDirectories: true, attributes: nil)
                    }
                }

                print("    🟢 Press enter to continue...")
                _ = readLine()
            }
        }
    }
}

private extension Reviewer {
    func sameContents(_ files: ProcessedFile) throws -> Bool {
        do {
            let generatedFile = try File(path: files.generatedFile)
            let generatedFileData = try generatedFile.read()

            let projectFile = try File(path: files.projectFile)
            let projectFileData = try projectFile.read()

            return generatedFileData == projectFileData
        } catch {
            return false
        }
    }
}
