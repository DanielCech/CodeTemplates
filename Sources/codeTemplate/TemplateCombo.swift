//
//  TemplateCombo.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

/// Combination of several templates
public enum TemplateCombo: String {
    // Scenes
    case scene
    case sceneViewControllerRxSwift = "scene-ViewController-RxSwift"
    case sceneViewControllerRxSwiftWithTableView = "scene-ViewController-RxSwift-TableView"
    case sceneViewControllerRxSwiftWithFormTableView = "scene-ViewController-RxSwift-FormTableView"
    case sceneViewControllerRxSwiftWithCollectionView = "scene-ViewController-RxSwift-CollectionView"

    func perform(context: Context) throws {
        switch self {
        case .scene:
            try Generator.shared.generate(generationMode: .template("viewController"), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template("viewModel"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("storyboard-ViewController"), context: context, deleteGenerated: false)

        case .sceneViewControllerRxSwift:
            break

        case .sceneViewControllerRxSwiftWithTableView:
            try Generator.shared.generate(generationMode: .template("viewController-RxSwift-TableView"), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template("viewModel-RxSwift-TableView"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("viewModelAssembly"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("rxDataSourcesSectionType"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("storyboard-ViewController-TableView"), context: context, deleteGenerated: false)

            if context["sectionHeader"] != nil {
                try Generator.shared.generate(generationMode: .template("tableViewSectionHeader"), context: context, deleteGenerated: false)
            }

            if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
                for cell in unwrappedNewCells {
                    let modifiedContext = updateComboContext(context, name: cell)
                    try Generator.shared.generate(generationMode: .template("tableViewCellRxSwift"), context: modifiedContext, deleteGenerated: false)
                }
            }

        case .sceneViewControllerRxSwiftWithFormTableView:
            try Generator.shared.generate(generationMode: .template("viewController-RxSwift-FormTableView"), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template("viewModel-RxSwift-FormTableView"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("viewModelAssembly"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("rxDataSourcesSectionType"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("storyboard-ViewController-TableView"), context: context, deleteGenerated: false)

            if context["sectionHeader"] != nil {
                try Generator.shared.generate(generationMode: .template("tableViewSectionHeader"), context: context, deleteGenerated: false)
            }

            if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
                for cell in unwrappedNewCells {
                    let modifiedContext = updateComboContext(context, name: cell)
                    try Generator.shared.generate(generationMode: .template("tableViewCell-RxSwift-TextField"), context: modifiedContext, deleteGenerated: false)
                }
            }

        case .sceneViewControllerRxSwiftWithCollectionView:
            try Generator.shared.generate(generationMode: .template("viewController-RxSwift-CollectionView"), context: context, deleteGenerated: true)
            try Generator.shared.generate(generationMode: .template("viewModel-RxSwift-CollectionView"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("viewModelAssembly"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("rxDataSourcesSectionType"), context: context, deleteGenerated: false)
            try Generator.shared.generate(generationMode: .template("storyboard-ViewController-CollectionView"), context: context, deleteGenerated: false)

            if context["sectionHeader"] != nil {
                try Generator.shared.generate(generationMode: .template("tableViewSectionHeader"), context: context, deleteGenerated: false)
            }

            if let unwrappedNewCells = context["newCollectionViewCells"] as? [String] {
                for cell in unwrappedNewCells {
                    let modifiedContext = updateComboContext(context, name: cell)
                    try Generator.shared.generate(generationMode: .template("collectionViewCell-RxSwift"), context: modifiedContext, deleteGenerated: false)
                }
            }
        }
    }

    /// Modification of context for combo generation
    func updateComboContext(_ context: Context, name: String) -> Context {
        var modifiedContext = context
        modifiedContext["name"] = name
        modifiedContext["Name"] = name.pascalCased()
        return modifiedContext
    }
}
