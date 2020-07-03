//
//  ContextHelper.swift
//  codeTemplate
//
//  Created by Daniel Cech on 04/07/2020.
//

import Foundation

class ContextHelper {
    static let shared = ContextHelper()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }()

    func updateContext(_ context: Context) -> Context {
        var modifiedContext = context
        for key in context.keys {
            guard let stringValue = context[key] as? String else { continue }
            modifiedContext[key.pascalCased()] = stringValue.pascalCased()
        }

        modifiedContext["date"] = dateFormatter.string(from: Date())

        // Table view cells

        var tableViewCells = [String]()

        if let unwrappedOldTableViewCells = context["oldTableViewCells"] as? [String] {
            tableViewCells.append(contentsOf: unwrappedOldTableViewCells)
        }

        if let unwrappedNewTableViewCells = context["newTableViewCells"] as? [String] {
            tableViewCells.append(contentsOf: unwrappedNewTableViewCells)
        }

        modifiedContext["tableViewCells"] = tableViewCells

        // Collection view cells

        var collectionViewCells = [String]()

        if let unwrappedOldCollectionViewCells = context["oldCollectionViewCells"] as? [String] {
            collectionViewCells.append(contentsOf: unwrappedOldCollectionViewCells)
        }

        if let unwrappedNewCollectionViewCells = context["newCollectionViewCells"] as? [String] {
            collectionViewCells.append(contentsOf: unwrappedNewCollectionViewCells)
        }

        modifiedContext["collectionViewCells"] = collectionViewCells

        modifiedContext["Screen"] = modifiedContext["Name"]

        if let unwrappedProjectFiles = context["projectFiles"] as? [String] {
            modifiedContext["projectFiles"] = unwrappedProjectFiles.map { ProjectFile(name: $0, uuid: String.randomFileUUID()) }
        }

        return modifiedContext
    }
}