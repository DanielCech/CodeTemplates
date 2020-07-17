//
//  Preparator.swift
//  codeTemplate
//
//  Created by Daniel Cech on 17/07/2020.
//

import Foundation

class Preparator {
    public static let shared = Preparator()
    
    func prepareTemplate(_ template: Template, category: String, contextFile: String) throws {
        let context = try ContextHelper.shared.context(fromFile: contextFile)
    }
    
}
