//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
    func pascalCased() -> String {
        let first = String(prefix(1)).uppercased()
        let other = String(dropFirst())
        return first + other
    }

    mutating func pascalCase() {
        self = pascalCased()
    }

    func camelCased() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }

    mutating func camelCase() {
        self = camelCased()
    }

    func modifyName(context: Context) -> String {
        var newName = replacingOccurrences(of: ".stencil", with: "")
        for key in context.keys {
            guard let stringValue = context[key] as? String else { continue }
            newName = newName.replacingOccurrences(of: "{{\(key)}}", with: stringValue)
        }
        return newName
    }

    static func randomFileUUID() -> String {
        return "273AB" + (0 ..< 11).map { _ in "0123456789ABCDEF".randomElement()! } + "00F30E8D"
    }
}
