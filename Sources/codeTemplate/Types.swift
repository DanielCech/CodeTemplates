//
//  Types.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public typealias Context = [String: Any]
public typealias ProcessedFile = (templateFile: String, generatedFile: String, projectFile: String?)

public enum ReviewMode {
    case none
    case individual
    case overall
}

public enum GenerationMode {
    case template(TemplateType)
    case combo(TemplateCombo)
}
