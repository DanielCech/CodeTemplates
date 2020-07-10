//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
    
    /// Conversion to PascalCase
    func pascalCased() -> String {
        let first = String(prefix(1)).uppercased()
        let other = String(dropFirst())
        return first + other
    }

    /// Conversion to PascalCase
    mutating func pascalCase() {
        self = pascalCased()
    }

    /// Conversion to camelCase
    func camelCased() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }

    /// Conversion to camelCase
    mutating func camelCase() {
        self = camelCased()
    }

    /// File name modification based on substitutions from context
    func modifyName(context: Context) -> String {
        var newName = replacingOccurrences(of: ".stencil", with: "")
        for key in context.keys {
            guard let stringValue = context[key] as? String else { continue }
            newName = newName.replacingOccurrences(of: "{{\(key)}}", with: stringValue)
        }
        return newName
    }
}
