//
//  ContextProvider.swift
//  codeTemplate
//
//  Created by Daniel Cech on 24/07/2020.
//

import Files
import Foundation
import Moderator
import ScriptToolkit

class ContextProvider {
    static let shared = ContextProvider()

    private static var boolParameters = [String: FutureValue<Bool>]()
    private static var stringParameters = [String: FutureValue<String?>]()
    private static var stringArrayParameters = [String: FutureValue<[String]>]()
    private static var help: FutureValue<Bool>!

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }()

    private static var moderator: Moderator!
    private(set) static var context: Context!

    static func getContext() -> Context {
        return context
    }

    static func setupParameters() {
        moderator = Moderator(description: "Generates a swift app components from templates")
        moderator.usageFormText = "codeTemplate <params>"

        for parameter in BoolParameter.allCases {
            boolParameters[parameter.rawValue] = moderator.add(.option(parameter.rawValue, description: parameter.description))
        }

        for parameter in StringParameter.allCases {
            stringParameters[parameter.rawValue] = moderator.add(Argument<String?>
                .optionWithValue(parameter.rawValue, name: parameter.name, description: parameter.description))
        }

        for parameter in StringArrayParameter.allCases {
            stringArrayParameters[parameter.rawValue] = moderator.add(Argument<String?>.singleArgument(name: parameter.rawValue, description: parameter.name).repeat())
        }

        help = moderator.add(.option("h","help", description: "Show this parameter documentation"))
    }

    static func parseParameters() throws {
        try moderator.parse()

        if let contextFileValue = stringParameters["context"], let contextFile = contextFileValue.value {
            context = try loadContext(fromFile: contextFile)
        } else {
            if !help.value { print("⚠️  Context is missing") }
            context = [:]
        }

        // Overwrite context with command line parameters
        for parameter in BoolParameter.allCases {
            if let commandLineValue = boolParameters[parameter.rawValue]?.value {
                context[parameter.rawValue] = commandLineValue
            }

            if context[parameter.rawValue] == nil, let defaultValue = parameter.defaultValue {
                context[parameter.rawValue] = defaultValue
            }
        }

        for parameter in StringParameter.allCases {
            if let commandLineValue = stringParameters[parameter.rawValue]?.value {
                context[parameter.rawValue] = commandLineValue
            }
            if context[parameter.rawValue] == nil, let defaultValue = parameter.defaultValue {
                context[parameter.rawValue] = defaultValue
            }
        }

        for parameter in StringArrayParameter.allCases {
            if let commandLineValue = stringArrayParameters[parameter.rawValue]?.value, commandLineValue.count > 0 {
                context[parameter.rawValue] = commandLineValue
            }
            if context[parameter.rawValue] == nil, let defaultValue = parameter.defaultValue {
                context[parameter.rawValue] = defaultValue
            }
        }
    }

    static func showUsageInfoIfNeeded() {
        if help.value {
            print(moderator.usagetext)
            exit(0)
        }
    }

    /// Default operations with context - default content, case processing, ...
    static func updateContext(_ context: Context) -> Context {
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

        if let unwrappedOldTableViewCells = context.optionalStringArrayValue(.oldTableViewCells) {
            tableViewCells.append(contentsOf: unwrappedOldTableViewCells)
        }

        if let unwrappedNewTableViewCells = context.optionalStringArrayValue(.newTableViewCells) {
            tableViewCells.append(contentsOf: unwrappedNewTableViewCells)
        }

        modifiedContext["tableViewCells"] = tableViewCells

        // Collection view cells

        var collectionViewCells = [String]()

        if let unwrappedOldCollectionViewCells = context.optionalStringArrayValue(.oldCollectionViewCells) {
            collectionViewCells.append(contentsOf: unwrappedOldCollectionViewCells)
        }

        if let unwrappedNewCollectionViewCells = context.optionalStringArrayValue(.newCollectionViewCells) {
            collectionViewCells.append(contentsOf: unwrappedNewCollectionViewCells)
        }

        modifiedContext["collectionViewCells"] = collectionViewCells

        modifiedContext["Screen"] = modifiedContext["Name"]

        return modifiedContext
    }
}

private extension ContextProvider {
    static func loadContext(fromFile contextFile: String) throws -> Context {
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