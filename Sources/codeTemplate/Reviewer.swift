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
            compareTwoItems(first: Paths.generatedPath, second: Paths.locationPath)

        case .individual:
            for processedFile in processedFiles {
                compareThreeItems(first: processedFile.templateFile, second: processedFile.generatedFile, third: processedFile.projectFile)

                print(processedFile.generatedFile.lastPathComponent + ":")
                print("🟢 Press any key to continue...")
                _ = readLine()
            }
        }
    }
}
