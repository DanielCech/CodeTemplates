//
//  CodeTemplateError.swift
//  codeTemplate
//
//  Created by Daniel Cech on 10/07/2020.
//

import Foundation
import ScriptToolkit

enum CodeTemplateError: Error {
    case stencilTemplateError(message: String)
}

extension CodeTemplateError: PrintableError {
    var errorDescription: String {
        let prefix = "💥 error: "
        var errorDescription = ""
        
        switch self {
        case let .stencilTemplateError(message):
            errorDescription = "stencil syntax error: \(message)"
        }
        
        return prefix + errorDescription
    }
}
