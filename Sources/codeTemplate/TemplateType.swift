//
//  TemplateType.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public enum TemplateType: String {
    // View Controllers
    case viewControllerBasic
    case viewControllerRxSwift
    case viewControllerRxSwiftWithTableView
    case viewControllerRxSwiftWithCollectionView

    // View Models
    case viewModelBasic
    case viewModelRxSwift
    case viewModelRxSwiftWithTableView
    case viewModelRxSwiftWithCollectionView

    // Table View Cells
    case tableViewCell
    case tableViewCellRxSwift

    // Table View Section Header
    case tableViewSectionHeader

    // Table View Cell View Models
    case tableViewCellViewModel
    case tableViewCellViewModelRxSwift

    // Collection View Cells
    case collectionViewCell
    case collectionViewCellRxSwift

    // Collection View Cell View Models
    case collectionViewCellViewModel
    case collectionViewCellViewModelRxSwift

    // Storyboards
    case storyboardViewController
    case storyboardViewControllerWithTableView
    case storyboardViewControllerWithCollectionView

    // Views
    case view

    // XIBs
    case xibView

    // Coordinators
    case coordinator
    case coordinatorNavigation

    // Section types
    case tableViewSectionType
    case collectionViewSectionType

    // Common parts
    case viewModelAssembly

    func basePath() -> String {
        switch self {
        case .viewModelAssembly:
            return projectPath
        default:
            return scenePath
        }
    }
}
