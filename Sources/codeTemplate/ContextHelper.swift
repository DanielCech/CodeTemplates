//
//  ContextHelper.swift
//  codeTemplate
//
//  Created by Daniel Cech on 04/07/2020.
//

import Foundation
import Files
import ScriptToolkit

class ContextHelper {
    static let shared = ContextHelper()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }()

    /// Default operations with context - default content, case processing, ...
    func updateContext(_ context: Context) -> Context {
        var modifiedContext = context

        if modifiedContext["coordinator"] == nil {
            modifiedContext["coordinator"] = modifiedContext["name"]
        }

        if modifiedContext["target"] == nil {
            modifiedContext["target"] = modifiedContext["projectName"]
        }

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

        return modifiedContext
    }
    
    func context(fromFile contextFile: String) throws -> Context {
        let contextFile = try File(path: contextFile)
        let contextString = try contextFile.readAsString(encodedAs: .utf8)
        let contextData = Data(contextString.utf8)

        // make sure this JSON is in the format we expect
        guard let context = try JSONSerialization.jsonObject(with: contextData, options: []) as? [String: Any] else {
            throw ScriptError.generalError(message: "Deserialization error")
        }
        
        return context
    }
}
