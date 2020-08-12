//
//  Types.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

/// Tuple of template file, generated file and project file that are related to the same file
public typealias ProcessedFile = (templateFile: String, generatedFile: String, projectFile: String)

/// Review mode after code generation
public enum ReviewMode: String {
    /// Do not review
    case none

    /// Review files separately
    case individual

    /// Review files together as folder comparison
    case overall
}

/// Generate code using single template or template combo
public enum GenerationMode {
    case template(Template)
    case combo(TemplateCombo)
}

/// The way howo templates should be updated
public enum UpdateTemplateMode: String {
    /// Update all templates
    case all

    /// Update only when parent template modification date is newer than child template modification date
    case new
}

/// For particular template, we want to update also:
public enum UpdateScopeMode: String {
    /// Update all ancestors of current template
    case acestors

    /// Update all descendants of current template
    case descendants

    /// Update ancestors and descendants
    case both
}

/// The current program operation - generate code, update template or validate template
public enum ProgramMode {
    case generateCode(Context)
    case updateTemplates(UpdateTemplateMode)
    case validateTemplates
    case prepareTemplate
}

public enum TemplateDestination: String {
    case project = "_project"
    case sources = "_sources"
    case location = "_location"
}
