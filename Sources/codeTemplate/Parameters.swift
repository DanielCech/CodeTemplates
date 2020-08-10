//
//  Parameters.swift
//  codeTemplate
//
//  Created by Daniel Cech on 24/07/2020.
//

import Foundation

protocol ParameterDescriptive {
    var name: String { get }
    var description: String { get }
}

enum BoolParameter: String, CaseIterable, ParameterDescriptive {
    ///  Using scrolling fake navbar
    case fakeNavbar

    /// Support for tableview section headers
    case tableSectionHeaders

    /// Table has header
    case tableViewHeader

    /// Table has footer
    case tableViewFooter

    /// Loads table content from API
    case tableContentFromAPI

    /// Table views has white selected state (touch is not visible)
    case whiteCellSelection

    /// Shows buttons at the bottom of table in controller
    case bottomView

    /// Top alpha gradient
    case topGradientView

    /// Bottom alpha gradient
    case bottomGradientView

    var description: String {
        switch self {
        case .fakeNavbar:
            return "Use of fake navbar view that collapses after scroll"
        case .tableSectionHeaders:
            return "Support for table section headers"
        case .tableViewHeader:
            return "Use table view header"
        case .tableViewFooter:
            return "Use table view footer"
        case .tableContentFromAPI:
            return "Support for table view intialization from API"
        case .whiteCellSelection:
            return "Setup selection color for table view cell"
        case .bottomView:
            return "Use view stuck at the bottom of table controller"
        case .topGradientView:
            return "Use simple view with top alpha gradient (for table/collection view screens)"
        case .bottomGradientView:
            return "Use simple view with bottom alpha gradient (for table/collection view screens)"
        }
    }

    var name: String { return "" }

    var defaultValue: Bool? {
        switch self {
        case .fakeNavbar:
            return false
        case .tableSectionHeaders:
            return false
        case .tableViewHeader:
            return false
        case .tableViewFooter:
            return false
        case .tableContentFromAPI:
            return false
        case .whiteCellSelection:
            return true
        case .bottomView:
            return false
        case .topGradientView:
            return false
        case .bottomGradientView:
            return false
        }
    }
}

enum StringParameter: String, CaseIterable, ParameterDescriptive {
    /// JSON file with template context
    case context

    /// Current operation mode - code generation, updating templates and template validation
    case mode

    /// Code template name
    case template

    /// Combination of templates
    case templateCombo

    /// Template category name
    case category

    /// Generator result review mode
    case reviewMode

    /// Location of CodeTemplate
    case scriptPath

    /// Location of souce code
    case locationPath

    /// Location of the project
    case projectPath

    /// Location of project source files
    case sourcesPath
    
    /// Location of templates - codeTemplate/Templates
    case templatePath
    
    /// Location of folder for generation - codeTemplate/Generate
    case generatePath
    
    /// Location of folder for validation - codeTemplate/Validate
    case validatePath
    
    /// Location of folder for preparation - codeTemplate/Prepare
    case preparePath

    /// The name of created item (decapitalized), Name - capitalized name
    case name

    /// The author of project, used in title
    case author

    ///  Project name and target name
    case projectName

    /// Copyright phrase used in file header
    case copyright

    /// The name of generated screen; used in combination with cell name
    case screen

    /// The name of coordinator which is related to the scene - name doesn't contain "Coordinator" or "Coordinating"
    case coordinator

    /// The name of template as origin for template preparation
    case deriveFromTemplate

    var name: String {
        switch self {
        case .context:
            return "Template context"
        case .mode:
            return "Current operation mode - code generation, updating templates and template validation"
        case .template:
            return "Code template name"
        case .category:
            return "Template category name"
        case .reviewMode:
            return "Generator result review mode"
        case .scriptPath:
            return "The location of CodeTemplate"
        case .name:
            return "Name that should be replaced by placeholder"
        case .author:
            return "Author of file"
        case .projectName:
            return "The name of project"
        case .copyright:
            return "The copyright phrase"
        case .screen: // TODO: check
            return "the name of generated screen"
        case .coordinator:
            return "The name of coordinator which is related to the scene"
        case .locationPath:
            return "Location of generated feature in project"
        case .projectPath:
            return "Location of project"
        case .sourcesPath:
            return "Location of project source files"
        case .templateCombo:
            return "Combination of templates"
        case .deriveFromTemplate:
            return "The name of template as origin for template preparation"
        case .templatePath:
            return "Location of templates - codeTemplate/Templates"
        case .generatePath:
            return "Location of folder for generation - codeTemplate/Generate"
        case .validatePath:
            return "Location of folder for validation - codeTemplate/Validate"
        case .preparePath:
            return "Location of folder for preparation - codeTemplate/Prepare"
        }
    }

    var description: String {
        switch self {
        case .context:
            return "JSON file with template context - parameter definitions"
        case .mode:
            return "Possible values: generate, updateAll, updateNew, validate, prepare"
        case .template:
            return ""
        case .templateCombo:
            return ""
        case .category:
            return "Use with prepare mode only"
        case .reviewMode:
            return "Possible values: none, individual, overall"
        case .scriptPath:
            return "The path to codeTemplate script with Generate and Templates folder."
        case .name:
            return ""
        case .author:
            return "Visible in source file header"
        case .projectName:
            return "Visible in source file header"
        case .copyright:
            return "Visible in source file header. Example: 'Copyright © 2020 STRV. All rights reserved.'"
        case .screen:
            return "Used in combination with cell name"
        case .coordinator:
            return "The name doesn't contain 'Coordinator' or 'Coordinating'"
        case .locationPath:
            return ""
        case .projectPath:
            return ""
        case .sourcesPath:
            return ""
        case .templatePath:
            return ""
        case .generatePath:
            return ""
        case .validatePath:
            return ""
        case .preparePath:
            return ""
        case .deriveFromTemplate:
            return ""
        }
    }

    var defaultValue: String? {
        switch self {
        case .reviewMode:
            return "individual"
        case .scriptPath:
            // TODO: implement using environment variables
            return "/Users/danielcech/Documents/[Development]/[Projects]/codeTemplate"
        default:
            return nil
        }
    }
}

enum StringArrayParameter: String, CaseIterable, ParameterDescriptive {
    /// Already defined table view cells
    case oldTableViewCells

    /// Table view cells that need to be generated
    case newTableViewCells

    /// All table view cells together
    case tableViewCells

    /// Already defined collection view cells
    case oldCollectionViewCells

    /// Collection view cells that need to be generated
    case newCollectionViewCells

    /// All collection view cells together
    case collectionViewCells

    /// The set of files for template preparation
    case projectFiles

    var name: String {
        switch self {
        case .oldTableViewCells:
            return "List of tableViewCells that are already defined in project"
        case .newTableViewCells:
            return "List of tableViewCells that should be prepared"
        case .tableViewCells:
            return "Old and new table view cells together"
        case .oldCollectionViewCells:
            return "List of collectionViewCells that are already defined in project"
        case .newCollectionViewCells:
            return "List of collectionViewCells that should be prepared"
        case .collectionViewCells:
            return "Old and new collection view cells together"
        case .projectFiles:
            return "The set of files for template preparation"
        }
    }

    var description: String {
        return ""
    }

    var defaultValue: [String]? {
        return nil
    }
}
