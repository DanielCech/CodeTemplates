//
//  TemplateType.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public enum TemplateType: String, CaseIterable {
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

    // Coordinators
    case coordinator
    case coordinatorNavigation

    // Section types
    case rxDataSourcesSectionType

    // Common parts
    case viewModelAssembly
    
    // Snippets
    case halfModalContainerViewController
    case interpolate
    case screenListViewController
    case stylesheet

    var category: TemplateCategory {
        switch self {
        case .viewControllerBasic, .viewControllerRxSwift, .viewControllerRxSwiftWithTableView, .viewControllerRxSwiftWithCollectionView:
            return .viewController

        case .viewModelBasic, .viewModelRxSwift, .viewModelRxSwiftWithTableView, .viewModelRxSwiftWithCollectionView:
            return .viewModel

        case .tableViewCell,.tableViewCellRxSwift:
            return .tableViewCell

        case .tableViewSectionHeader:
            return .tableViewSectionHeader

        case .tableViewCellViewModel,.tableViewCellViewModelRxSwift:
            return .tableViewCellViewModel

        case .collectionViewCell, .collectionViewCellRxSwift:
            return .collectionViewCell

        case .collectionViewCellViewModel, .collectionViewCellViewModelRxSwift:
            return .collectionViewCellViewModel

        case .storyboardViewController, .storyboardViewControllerWithTableView, .storyboardViewControllerWithCollectionView:
            return .storyboard

        case .view:
            return .view

        case .coordinator, .coordinatorNavigation:
            return .coordinator

        case .rxDataSourcesSectionType:
            return .rxDataSourcesSectionType

        case .viewModelAssembly:
            return .viewModelAssembly
            
        case .halfModalContainerViewController, .interpolate, .screenListViewController, .stylesheet:
            return .snippets
        }
    }

    func basePath() -> String {
        switch self {
        case .viewModelAssembly:
            return Paths.projectPath
        default:
            return Paths.scenePath
        }
    }
}

var templateDependencies: [TemplateType: [TemplateType]] = [
    // View
    .view: [.tableViewCell, .tableViewSectionHeader, .collectionViewCell],
    
    // View Controllers
    .viewControllerBasic: [.viewControllerRxSwift, .halfModalContainerViewController, .screenListViewController],
    .viewControllerRxSwift: [.viewControllerRxSwiftWithTableView, .viewControllerRxSwiftWithCollectionView],
    
    // View Models
    .viewModelBasic: [.viewModelRxSwift, .tableViewCellViewModel, .collectionViewCellViewModel],
    .viewModelRxSwift: [.viewModelRxSwiftWithTableView, .viewModelRxSwiftWithCollectionView, .tableViewCellViewModelRxSwift, .collectionViewCellViewModelRxSwift],
    
    // Table View Cells
    .tableViewCell: [.tableViewCellRxSwift],
    
    // Collection View Cells
    .collectionViewCell: [.collectionViewCellRxSwift],
    
    // Coordinators
    .coordinator: [.coordinatorNavigation],
]
