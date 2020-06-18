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

func compareTwoItems(first: String, second: String) {
    let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" \"" + first + "\" \"" + second + "\""
    shell(command)
}

func compareThreeItems(first: String, second: String, third: String) {
    let command = "\"/Applications/Araxis Merge.app/Contents/Utilities/compare\" -3 \""
        + first + "\" \""
        + second + "\" \""
        + third + "\""
    shell(command)
    shell(command)
}

class Reviewer {
    static let shared = Reviewer()

    func review(mode: ReviewMode, processedFiles: [ProcessedFile]) throws {
        switch mode {
        case .none:
            break

        case .overall:
            compareTwoItems(first: Paths.generatedPath, second: Paths.scenePath)

        case .individual:
            for processedFile in processedFiles {
                if let unwrappedProjectFile = processedFile.projectFile {
                    compareThreeItems(first: processedFile.templateFile, second: processedFile.generatedFile, third: unwrappedProjectFile)
                } else {
                    compareTwoItems(first: processedFile.templateFile, second: processedFile.generatedFile)
                }

                print(processedFile.generatedFile.lastPathComponent + ":")
                print("🟢 Press any key to continue...")
                _ = readLine()
            }
        }
    }
}
