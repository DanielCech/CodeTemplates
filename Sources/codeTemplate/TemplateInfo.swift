//
//  TemplateInfo.swift
//  codeTemplate
//
//  Created by Daniel Cech on 07/07/2020.
//

import Foundation

struct TemplateInfo {
    /// Category of template - the first level of folder structure
    var category: String

    /// Subjective measure - how well is template prepared?
    var completeness: Int

    /// Is template separately compilable and validatable?
    var compilable: Bool

    /// Context for template validation - for validation purposes
    var context: Context

    /// Set of bool variables - the different setup of template - for validation purposes
    var switches: [String]
}
