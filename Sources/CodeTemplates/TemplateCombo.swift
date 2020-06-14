//
//  TemplateCombo.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public enum TemplateCombo {
    
    // Scenes
    case scene
    case sceneControllerRxSwift
    case sceneControllerRxSwiftWithTableView
    case sceneControllerRxSwiftWithCollectionView
    
    func perform(context: Context) throws {
        switch self {
            
        case .scene:
            try Generator.shared.generate(generationMode: .template(.viewControllerBasic), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template(.viewModelBasic), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.storyboardViewController), context: context, deleteGenerated: false)
            
            
        case .sceneControllerRxSwift:
            break
            
        case .sceneControllerRxSwiftWithTableView:            
            try Generator.shared.generate(generationMode: .template(.viewControllerRxSwiftWithTableView), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template(.viewModelRxWithTableView), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.storyboardViewControllerWithTableView), context: context, deleteGenerated: false)
            
        case .sceneControllerRxSwiftWithCollectionView:
            break
        }
    }
}
