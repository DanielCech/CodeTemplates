//
//  ContextExtension.swift
//  codeTemplate
//
//  Created by Daniel Cech on 10/08/2020.
//

import Foundation

extension Context {
    func boolValue(_ parameter: BoolParameter) -> Bool {
        if let boolValue = dictionary[parameter.rawValue] as? Bool {
            return boolValue
        }

        var newValue = ""

        while true {
            var description: String
            if parameter.description.isEmpty {
                description = "\nℹ️  Missing parameter '\(parameter)': \(parameter.name)"
            } else {
                description = "\nℹ️  Missing parameter '\(parameter)': \(parameter.name). \(parameter.description)."
            }

            print(description)
            print("❔ Enter '\(parameter)' [tf]: ", terminator: "")

            if let input = readLine(), !input.isEmpty, input == "t" || input == "f" {
                newValue = input
                break
            } else {
                print("❗️ Incorrect input")
            }
        }

        let trueOrFalse = (newValue == "t") ? true : false
        dictionary[parameter.rawValue] = trueOrFalse

        return trueOrFalse
    }

    func optionalBoolValue(_ parameter: BoolParameter) -> Bool? {
        if let boolValue = dictionary[parameter.rawValue] as? Bool {
            return boolValue
        }

        return nil
    }

    func stringValue(_ parameter: StringParameter) -> String {
        if let stringValue = dictionary[parameter.rawValue] as? String {
            return stringValue
        }

        var newValue = ""

        while true {
            var description: String
            if parameter.description.isEmpty {
                description = "\nℹ️  Missing parameter '\(parameter)':' \(parameter.name)"
            } else {
                description = "\nℹ️  Missing parameter '\(parameter)': \(parameter.name). \(parameter.description)."
            }

            print(description)
            print("❔ Enter '\(parameter)': ", terminator: "")

            if let input = readLine(), !input.isEmpty {
                newValue = input
                break
            } else {
                print("❗️ Incorrect input")
            }
        }

        dictionary[parameter.rawValue] = newValue

        return newValue
    }

    func optionalStringValue(_ parameter: StringParameter) -> String? {
        if let stringValue = dictionary[parameter.rawValue] as? String {
            return stringValue
        }
        return nil
    }

    func stringArrayValue(_ parameter: StringArrayParameter) -> [String] {
        if let stringArrayValue = dictionary[parameter.rawValue] as? [String] {
            return stringArrayValue
        }

        guard let stringArrayParameter = StringArrayParameter(rawValue: parameter.rawValue) else {
            fatalError("Unknown string array parameter \(parameter)")
        }

        var newValue = ""

        while true {
            var description: String
            if stringArrayParameter.description.isEmpty {
                description = "\nℹ️  Missing parameter '\(parameter)': \(stringArrayParameter.name)"
            } else {
                description = "\nℹ️  Missing parameter '\(parameter)': \(stringArrayParameter.name). \(stringArrayParameter.description)."
            }

            print(description)
            print("❔ Enter '\(parameter)' (comma-separated): ", terminator: "")

            if let input = readLine(), !input.isEmpty {
                newValue = input
                break
            } else {
                print("❗️ Incorrect input")
            }
        }

        let list = newValue.split(separator: ",").map { String($0) }
        dictionary[parameter.rawValue] = list

        return list
    }

    func optionalStringArrayValue(_ parameter: StringArrayParameter) -> [String]? {
        if let stringArrayValue = dictionary[parameter.rawValue] as? [String] {
            return stringArrayValue
        }
        return nil
    }

    subscript(parameter: BoolParameter) -> Bool? {
        get {
            optionalBoolValue(parameter)
        }

        set {
            dictionary[parameter.rawValue] = newValue
        }
    }

    subscript(parameter: StringParameter) -> String? {
        get {
            optionalStringValue(parameter)
        }

        set {
            dictionary[parameter.rawValue] = newValue
        }
    }

    subscript(parameter: StringArrayParameter) -> [String]? {
        get {
            optionalStringArrayValue(parameter)
        }

        set {
            dictionary[parameter.rawValue] = newValue
        }
    }
}
