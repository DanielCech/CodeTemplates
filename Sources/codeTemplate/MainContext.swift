//
//  MainContext.swift
//  codeTemplate
//
//  Created by Daniel Cech on 24/07/2020.
//

import Foundation
import Moderator
import Files
import ScriptToolkit

class MainContext {
        
    static let shared = MainContext()
    
    private static var boolParameters = [String: FutureValue<Bool>]()
    private static var stringParameters = [String: FutureValue<String?>]()
    private static var stringArrayParameters = [String: FutureValue<[String]>]()
    
    private static var moderator: Moderator!
    private(set) static var context: Context!
    
    static func getContext() -> Context {
        return context
    }
    
    static func setupParameters() {
        moderator = Moderator(description: "Generates a swift app components from templates")
        moderator.usageFormText = "codeTemplate <params>"
        
        for parameter in BoolParameters.allCases {
            boolParameters[parameter.rawValue] = moderator.add(.option(parameter.rawValue, description: parameter.description))
        }
        
        for parameter in StringParameters.allCases {
            stringParameters[parameter.rawValue] = moderator.add(Argument<String?>
                .optionWithValue(parameter.rawValue, name: parameter.name, description: parameter.description))
        }
        
        for parameter in StringArrayParameters.allCases {
            stringArrayParameters[parameter.rawValue] = moderator.add(Argument<String?>.singleArgument(name: parameter.rawValue, description: parameter.name).repeat())
        }
    }
    
    static func parseParameters() throws {
        try moderator.parse()
        
        if let contextFileValue = stringParameters["context"], let contextFile = contextFileValue.value {
            context = try loadContext(fromFile: contextFile)
        }
        else {
            print("⚠️  Context is missing")
            context = [:]
        }
        
        // Overwrite context with command line parameters
        for parameter in BoolParameters.allCases {
            context[parameter.rawValue] = boolParameters[parameter.rawValue]?.value
        }
        
        for parameter in StringParameters.allCases {
            context[parameter.rawValue] = stringParameters[parameter.rawValue]?.value
        }
        
        for parameter in StringArrayParameters.allCases {
            context[parameter.rawValue] = stringArrayParameters[parameter.rawValue]?.value
        }
    }
    
    static func boolValue(_ parameter: String) -> Bool {
        if let boolValue = context[parameter] as? Bool {
            return boolValue
        }
        
        guard let boolParameter = BoolParameters(rawValue: parameter) else {
            fatalError("Unknown bool parameter \(parameter)")
        }
        
        var newValue = ""
        
        while true {
            var description: String
            if boolParameter.description.isEmpty {
                description = "\nℹ️  Missing parameter '\(parameter)': \(boolParameter.name)"
            }
            else {
                description = "\nℹ️  Missing parameter '\(parameter)': \(boolParameter.name). \(boolParameter.description)."
            }
            
            print(description)
            print("❔ Enter '\(parameter)' [tf]: ", terminator: "")
            
            if let input = readLine(), !input.isEmpty, input == "t" || input == "f" {
                newValue = input
                break
            }
            else {
                print("❗️ Incorrect input")
            }
        }
        
        let trueOrFalse = (newValue == "t") ? true : false
        context[parameter] = trueOrFalse
        
        return trueOrFalse
    }
    
    static func optionalBoolValue(_ parameter: String) -> Bool? {
        if let boolValue = context[parameter] as? Bool {
            return boolValue
        }
        
        return nil
    }
    
    static func stringValue(_ parameter: String) -> String {
        if let stringValue = context[parameter] as? String {
            return stringValue
        }
        
        guard let stringParameter = StringParameters(rawValue: parameter) else {
            fatalError("Unknown string parameter \(parameter)")
        }
        
        var newValue = ""
        
        while true {
            var description: String
            if stringParameter.description.isEmpty {
                description = "\nℹ️  Missing parameter '\(parameter)':' \(stringParameter.name)"
            }
            else {
                description = "\nℹ️  Missing parameter '\(parameter)': \(stringParameter.name). \(stringParameter.description)."
            }
            
            print(description)
            print("❔ Enter '\(parameter)': ", terminator: "")
            
            if let input = readLine(), !input.isEmpty {
                newValue = input
                break
            }
            else {
                print("❗️ Incorrect input")
            }
        }
        
        context[parameter] = newValue
        
        return newValue
    }
    
    static func optionalStringValue(_ parameter: String) -> String? {
        if let stringValue = context[parameter] as? String {
            return stringValue
        }
        return nil
    }
    
    static func stringArrayValue(_ parameter: String) -> [String] {
        if let stringArrayValue = context[parameter] as? [String] {
            return stringArrayValue
        }
        
        guard let stringArrayParameter = StringArrayParameters(rawValue: parameter) else {
            fatalError("Unknown string array parameter \(parameter)")
        }
        
        var newValue = ""
        
        while true {
            var description: String
            if stringArrayParameter.description.isEmpty {
                description = "\nℹ️  Missing parameter '\(parameter)': \(stringArrayParameter.name)"
            }
            else {
                description = "\nℹ️  Missing parameter '\(parameter)': \(stringArrayParameter.name). \(stringArrayParameter.description)."
            }
            
            print(description)
            print("❔ Enter '\(parameter)' (comma-separated): ", terminator: "")
            
            if let input = readLine(), !input.isEmpty {
                newValue = input
                break
            }
            else {
                print("❗️ Incorrect input")
            }
        }
        
        let list = newValue.split(separator: ",").map { String($0) }
        context[parameter] = list
        
        return list
    }
    
    static func optionalStringArrayValue(_ parameter: String) -> [String]? {
        if let stringArrayValue = context[parameter] as? [String] {
            return stringArrayValue
        }
        return nil
    }
}

private extension MainContext {
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
