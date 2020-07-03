//
//  TemplateCategory.swift
//  codeTemplate
//
//  Created by Daniel Cech on 18/06/2020.
//

import Foundation

public enum TemplateCategory: String {
    case viewController
    case viewModel
    case tableViewCell
    case tableViewSectionHeader

    // Table View Cell View Models
    case tableViewCellViewModel

    // Collection View Cells
    case collectionViewCell

    // Collection View Cell View Models
    case collectionViewCellViewModel

    // Storyboards
    case storyboard

    // Views
    case view

    // Coordinators
    case coordinator

    // Section types
    case rxDataSourcesSectionType

    // Common parts
    case viewModelAssembly

    // Code snippets
    case snippets

    // Xcode project
    case xcodeproj
}
