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
    case viewModelRxWithTableView
    case viewModelRxSwiftWithCollectionView
    
    // Table View Cells
    case tableViewCell
    case tableViewCellRxSwift
    
    // Table View Cell View Models
    case tableViewCellViewModel
    case tableViewCellViewModelRxSwift
    
    // Collection View Cells
    case collectionViewCell
    case collectionViewCellRxSwift
    
    // Collection View Cell View Models
    case collectionViewCellViewModel
    case collectionViewCellViewModelRxSwift
}
