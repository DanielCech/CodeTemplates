//
//  RegExpPatterns.swift
//  codeTemplate
//
//  Created by Daniel Cech on 30/07/2020.
//

import Foundation

enum RegExpPatterns {
    static let protocolPattern
        = #"""
        (?xi)
        .*\sprotocol\s.[^:]+:
        (?<commalist>
            .*
        )\s*\{
        """#

    static let extensionPattern
        = #"""
        (?xi)
        .*\sextension\s.[^:]+:
        (?<commalist>
            .*
        )\s*\{
        """#

    static let classPattern
        = #"""
        (?xi)
        .*\sclass\s.[^:]+:
        (?<commalist>
            .*
        )\s*\{
        """#

    static let structPattern
        = #"""
        (?xi)
        .*\sstruct\s.[^:]+:
        (?<commalist>
            .*
        )\s*\{
        """#

    static let enumPattern
        = #"""
        (?xi)
        .*\senum\s.[^:]+:
        (?<commalist>
            .*
        )\s*\{
        """#

    static let varPattern
        = #"""
        (?xi)
        .*\svar\s.[^:]+:
        (?<singleName>
            .*
        )\s*\{
        """#

    static let letPattern
        = #"""
        (?xi)
        .*\slet\s.[^:]+:
        (?<singleName>
            .*
        )\s*\{
        """#

    static let singleName
        = #"""
        (?xi)
        (?<exact>
            [A-Z][a-zA-Z0-9]*
        ).*
        """#
}
