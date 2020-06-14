//
//  TemplateCombo.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public enum TemplateCombo: String {
    
    // Scenes
    case scene
    case sceneControllerRxSwift
    case sceneControllerRxSwiftWithTableView
    case sceneControllerRxSwiftWithCollectionView
    
    func perform(context: Context) throws {
        switch self {
            
        case .scene:
            try generate(template: .viewControllerBasic, context: context, deleteGenerated: true)
            try generate(template: .viewModelBasic, context: context, deleteGenerated: false)
            try generate(template: .storyboardViewController, context: context, deleteGenerated: false)
            
            
        case .sceneControllerRxSwift:
            break
            
        case .sceneControllerRxSwiftWithTableView:
            try generate(template: .viewControllerRxSwiftWithTableView, context: context, deleteGenerated: true)
            try generate(template: .viewModelRxWithTableView, context: context, deleteGenerated: false)
            try generate(template: .storyboardViewControllerWithTableView, context: context, deleteGenerated: false)
            
        case .sceneControllerRxSwiftWithCollectionView:
            break
        }
    }
}
