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
            try Generator.shared.generate(generationMode: .template(.viewModelRxSwiftWithTableView), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.viewModelAssembly), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.tableViewSectionType), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.storyboardViewControllerWithTableView), context: context, deleteGenerated: false)

            if context["sectionHeader"] != nil {
                try Generator.shared.generate(generationMode: .template(.tableViewSectionHeader), context: context, deleteGenerated: false)
            }

            if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
                for cell in unwrappedNewCells {
                    let modifiedContext = updateComboContext(context, name: cell)
                    try Generator.shared.generate(generationMode: .template(.tableViewCellRxSwift), context: modifiedContext, deleteGenerated: false)
                }
            }

        case .sceneControllerRxSwiftWithCollectionView:
            try Generator.shared.generate(generationMode: .template(.viewControllerRxSwiftWithCollectionView), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template(.viewModelRxSwiftWithCollectionView), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.viewModelAssembly), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.collectionViewSectionType), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template(.storyboardViewControllerWithCollectionView), context: context, deleteGenerated: false)

            if context["sectionHeader"] != nil {
                try Generator.shared.generate(generationMode: .template(.tableViewSectionHeader), context: context, deleteGenerated: false)
            }

            if let unwrappedNewCells = context["newCollectionViewCells"] as? [String] {
                for cell in unwrappedNewCells {
                    let modifiedContext = updateComboContext(context, name: cell)
                    try Generator.shared.generate(generationMode: .template(.collectionViewCellRxSwift), context: modifiedContext, deleteGenerated: false)
                }
            }
        }
    }

    func updateComboContext(_ context: Context, name: String) -> Context {
        var modifiedContext = context
        modifiedContext["name"] = name
        modifiedContext["Name"] = name.pascalCased()
        return modifiedContext
    }
}
