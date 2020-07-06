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

        for parentTemplate in try Templates.shared.templateTypes().keys {
            guard let dependencies = try Templates.shared.templateDependencies()[parentTemplate] else { continue }

            let parentTemplateCategory = try Templates.shared.templateCategory(for: parentTemplate)
            guard let parentTemplateFolder = try? templateFolder.subfolder(at: parentTemplateCategory).subfolder(at: parentTemplate) else {
                throw ScriptError.folderNotFound(message: parentTemplateCategory + "/" + parentTemplate)
            }

            for childTemplate in dependencies {
                let childTemplateCategory = try Templates.shared.templateCategory(for: childTemplate)

                guard let childTemplateFolder = try? templateFolder.subfolder(at: childTemplateCategory).subfolder(at: childTemplate) else {
                    throw ScriptError.folderNotFound(message: childTemplateCategory + "/" + childTemplate)
                }

                print("⚙️ Updating: \(parentTemplate) to \(childTemplate)")
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

        // Process subfolders
        for parentSubfolder in parentTemplate.subfolders {
            guard let childSubfolder = try? childTemplate.subfolder(named: parentSubfolder.name) else { continue }

            try update(parentTemplate: parentSubfolder, childTemplate: childSubfolder, updateMode: updateMode, scriptPath: scriptPath)
        }
    }
}
