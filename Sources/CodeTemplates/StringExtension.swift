//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).uppercased()
        let other = String(self.dropFirst())
        return first + other
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func decapitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).lowercased()
        let other = String(self.dropFirst())
        return first + other
    }

    mutating func decapitalizeFirstLetter() {
        self = self.decapitalizingFirstLetter()
    }
    
    func modifyName(context: Context) -> String {
        var newName = self.replacingOccurrences(of: ".stencil", with: "")
        for key in context.keys {
            guard let stringValue = context[key] as? String else { continue }
            newName = newName.replacingOccurrences(of: "{{\(key)}}", with: stringValue)
        }
        return newName
    }
}
