//
//  TemplateInfo.swift
//  codeTemplate
//
//  Created by Daniel Cech on 07/07/2020.
//

import Foundation

struct TemplateInfo {
    /// category of template - the first level of folder structure
    var category: String

    // subjective measure - how well is template prepared?
    var completeness: Int

    // is template separately compilable and validatable?
    var compilable: Bool

    // context for template validation - for validation purposes
    var context: Context

    // set of bool variables - the different setup of template - for validation purposes
    var switches: [String]
}
