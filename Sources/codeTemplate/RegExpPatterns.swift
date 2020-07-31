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

    static let varPattern1
        = #"""
        (?xi)
        .*\svar\s.[^:]+:
        (?<singleName>
            .*
        )\s*\{
        """#
    
    static let varPattern2
        = #"""
        (?xi)
        .*\svar\s.[^=]+=
        (?<singleName>
            .*
        )\s*\{
        """#

    static let letPattern1
        = #"""
        (?xi)
        .*\slet\s.[^:]+:
        (?<singleName>
            .*
        )\s*\{
        """#
    
    static let letPattern2
        = #"""
        (?xi)
        .*\slet\s.[^=]+=
        (?<singleName>
            .*
        )\s*\{
        """#

    static let singleNamePattern
        = #"""
        (?xi)
        (?<exact>
            [A-Z][a-zA-Z0-9]*
        ).*
        """#
    
    static let importPattern
        = #"""
        (?xi)
        import\s
        (?<framework>
            [A-Z][a-zA-Z0-9]*
        ).*
        """#
}
