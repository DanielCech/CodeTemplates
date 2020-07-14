//
//  CodeTemplateError.swift
//  codeTemplate
//
//  Created by Daniel Cech on 10/07/2020.
//

import Files
import Foundation
import ScriptToolkit

enum CodeTemplateError: Error {
    case stencilTemplateError(message: String)
    case parameterNotSpecified(message: String)
}

extension CodeTemplateError: PrintableError {
    var errorDescription: String {
        let prefix = "💥 error: "
        var errorDescription = ""

        switch self {
        case let .stencilTemplateError(message):
            errorDescription = "stencil syntax error: \(message)"
        case let .parameterNotSpecified(message):
            errorDescription = "parameter not specified: \(message)"
        }

        return prefix + errorDescription
    }
}

extension FilesError: PrintableError {
    public var errorDescription: String {
        return description
    }
}
