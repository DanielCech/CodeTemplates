//
//  Types.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public typealias Context = [String: Any]
public typealias ProcessedFile = (templateFile: String, generatedFile: String, projectFile: String?)

public enum ReviewMode: String {
    case none
    case individual
    case overall
}

public enum GenerationMode {
    case template(Template)
    case combo(TemplateCombo)
}

public enum UpdateTemplateMode: String {
    case all // update all templates
    case new // update only when parent template modification date is newer than child template modification date
}

public enum ProgramMode {
    case generateCode(Context)
    case updateTemplates(UpdateTemplateMode)
    case validateTemplates
}

public struct ProjectFile {
    var name: String
    var uuid: String
}

public enum LocationRelativeTo: String {
    case project
    case sources
    case scene
}
