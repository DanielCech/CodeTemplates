//
//  Context.swift
//  codeTemplate
//
//  Created by Daniel Cech on 12/08/2020.
//

import Foundation

public class Context {
    var dictionary: [String: Any]
    var parentContext: Context?

    init() {
        dictionary = [:]
    }

    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    init(fromContext context: Context) {
        dictionary = context.dictionary
        parentContext = context
    }
}
