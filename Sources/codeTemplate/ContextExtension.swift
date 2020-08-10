//
//  ContextExtension.swift
//  codeTemplate
//
//  Created by Daniel Cech on 10/08/2020.
//

import Foundation

extension Context {
    mutating func boolValue(_ parameter: BoolParameter) -> Bool {
        if let boolValue = self[parameter.rawValue] as? Bool {
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
        self[parameter.rawValue] = trueOrFalse

        return trueOrFalse
    }

    func optionalBoolValue(_ parameter: BoolParameter) -> Bool? {
        if let boolValue = self[parameter.rawValue] as? Bool {
            return boolValue
        }

        return nil
    }

    mutating func stringValue(_ parameter: StringParameter) -> String {
        if let stringValue = self[parameter.rawValue] as? String {
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

        self[parameter.rawValue] = newValue

        return newValue
    }

    func optionalStringValue(_ parameter: StringParameter) -> String? {
        if let stringValue = self[parameter.rawValue] as? String {
            return stringValue
        }
        return nil
    }

    mutating func stringArrayValue(_ parameter: StringArrayParameter) -> [String] {
        if let stringArrayValue = self[parameter.rawValue] as? [String] {
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
        self[parameter.rawValue] = list

        return list
    }

    func optionalStringArrayValue(_ parameter: StringArrayParameter) -> [String]? {
        if let stringArrayValue = self[parameter.rawValue] as? [String] {
            return stringArrayValue
        }
        return nil
    }

    subscript(parameter: BoolParameter) -> Bool? {
        get {
            optionalBoolValue(parameter)
        }

        set {
            self[parameter.rawValue] = newValue
        }
    }

    subscript(parameter: StringParameter) -> String? {
        get {
            optionalStringValue(parameter)
        }

        set {
            self[parameter.rawValue] = newValue
        }
    }

    subscript(parameter: StringArrayParameter) -> [String]? {
        get {
            optionalStringArrayValue(parameter)
        }

        set {
            self[parameter.rawValue] = newValue
        }
    }
}
