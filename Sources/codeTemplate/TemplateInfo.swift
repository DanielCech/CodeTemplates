//
//  TemplateInfo.swift
//  codeTemplate
//
//  Created by Daniel Cech on 07/07/2020.
//

import Foundation

struct TemplateInfo {
    var category: String
    var completeness: Int
    var locationRelativeTo: LocationRelativeTo

    var context: Context
    var switches: [String]
}
