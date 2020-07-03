//
//  Updater.swift
//  codeTemplate
//
//  Created by Daniel Cech on 21/06/2020.
//

import Files
import Foundation
import ScriptToolkit

public class Updater {
    public static let shared = Updater()

    public func updateTemplates(updateMode: UpdateTemplateMode, scriptPath: String) throws {
        let templateFolder = try Folder(path: scriptPath).subfolder(named: "Templates")

        for parentTemplate in TemplateType.allCases {
            guard let dependencies = templateDependencies[parentTemplate] else { continue }

            guard let parentTemplateFolder = try? templateFolder.subfolder(at: parentTemplate.category.rawValue).subfolder(at: parentTemplate.rawValue) else {
                throw ScriptError.folderNotFound(message: parentTemplate.category.rawValue + "/" + parentTemplate.rawValue)
            }

            for childTemplate in dependencies {
                guard let childTemplateFolder = try? templateFolder.subfolder(at: childTemplate.category.rawValue).subfolder(at: childTemplate.rawValue) else {
                    throw ScriptError.folderNotFound(message: childTemplate.category.rawValue + "/" + childTemplate.rawValue)
                }

                print("⚙️ Updating: \(parentTemplate.rawValue) to \(childTemplate.rawValue)")
                try update(parentTemplate: parentTemplateFolder, childTemplate: childTemplateFolder, updateMode: updateMode, scriptPath: scriptPath)
            }
        }
    }
}

private extension Updater {
    func update(parentTemplate: Folder, childTemplate: Folder, updateMode: UpdateTemplateMode, scriptPath: String) throws {
        let templateFolder = try Folder(path: scriptPath).subfolder(named: "Templates")

        // Process files in folder
        for parentTemplateFile in parentTemplate.files where parentTemplateFile.name.lowercased().hasSuffix(".swift.stencil") {
            for childTemplateFile in childTemplate.files where childTemplateFile.name.lowercased().hasSuffix(".swift.stencil") {
                let parentTemplateFileModificationDate = try parentTemplateFile.modificationDate()
                let childTemplateFileModificationDate = try childTemplateFile.modificationDate()

                if updateMode == .all || (abs(parentTemplateFileModificationDate.distance(to: childTemplateFileModificationDate)) < 60) {
                    let parentTemplateFilePath = parentTemplateFile.path.replacingOccurrences(of: templateFolder.path, with: "")
                    let childTemplateFilePath = childTemplateFile.path.replacingOccurrences(of: templateFolder.path, with: "")

                    compareTwoItems(first: parentTemplateFile.path, second: childTemplateFile.path)

                    print("    1️⃣ \(parentTemplateFilePath)\n    2️⃣ \(childTemplateFilePath)")
                    print("    🟢 Press any key to continue...")
                    _ = readLine()

                    touch(file: parentTemplateFile.path)
                    touch(file: childTemplateFile.path)
                }
            }
        }

        guard let subfolders = try? parentTemplate.subfolders else {
            print("problem with \(parentTemplate.path) subfolders")
            return
        }

        // Process subfolders
        for parentSubfolder in subfolders {
            guard let childSubfolder = try? childTemplate.subfolder(named: parentSubfolder.name) else { continue }

            try update(parentTemplate: parentSubfolder, childTemplate: childSubfolder, updateMode: updateMode, scriptPath: scriptPath)
        }
    }
}
