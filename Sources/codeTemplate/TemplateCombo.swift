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
            try sceneCombo(context: context)

        case .sceneViewControllerRxSwift:
            try sceneViewControllerRxSwiftCombo(context: context)

        case .sceneViewControllerRxSwiftWithTableView:
            try sceneViewControllerRxSwiftWithTableViewCombo(context: context)

        case .sceneViewControllerRxSwiftWithFormTableView:
            try sceneViewControllerRxSwiftWithFormTableViewCombo(context: context)

        case .sceneViewControllerRxSwiftWithCollectionView:
            try sceneViewControllerRxSwiftWithCollectionViewCombo(context: context)
        }
    }

    /// Modification of context for combo generation
    func updateComboContext(_ context: Context, name: String) -> Context {
        var modifiedContext = context
        modifiedContext["name"] = name.camelCased()
        modifiedContext["Name"] = name.pascalCased()
        return modifiedContext
    }
}

// MARK: - Factories

private extension TemplateCombo {
    func sceneCombo(context: Context) throws {
        try Generator.shared.generate(generationMode: .template("viewController"), context: context, deleteGenerated: true)
        try Generator.shared.generate(generationMode: .template("viewModel"), context: context, deleteGenerated: false)
        try Generator.shared.generate(generationMode: .template("storyboard-ViewController"), context: context, deleteGenerated: false)

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftCombo(context: Context) throws {
        try Generator.shared.generate(generationMode: .template("viewController-RxSwif"), context: context, deleteGenerated: true)
        try Generator.shared.generate(generationMode: .template("viewModelAssembly"), context: context, deleteGenerated: false)
        try Generator.shared.generate(generationMode: .template("storyboard-ViewController"), context: context, deleteGenerated: false)

        if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(generationMode: .template("tableViewCell-RxSwift"), context: modifiedContext, deleteGenerated: false)
            }
        }

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithTableViewCombo(context: Context) throws {
        try Generator.shared.generate(generationMode: .template("viewController-RxSwift-TableView"), context: context, deleteGenerated: true)
        try Generator.shared.generate(generationMode: .template("viewModelAssembly"), context: context, deleteGenerated: false)
        try Generator.shared.generate(generationMode: .template("rxDataSourcesSectionType"), context: context, deleteGenerated: false)
        try Generator.shared.generate(generationMode: .template("storyboard-ViewController-TableView"), context: context, deleteGenerated: false)

        try generateHeadersAndFooters(context: context)

        if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(generationMode: .template("tableViewCell-RxSwift"), context: modifiedContext, deleteGenerated: false)
            }
        }

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithFormTableViewCombo(context: Context) throws {
        try Generator.shared.generate(generationMode: .template("viewController-RxSwift-FormTableView"), context: context, deleteGenerated: true)
        try Generator.shared.generate(generationMode: .template("viewModelAssembly"), context: context, deleteGenerated: false)
        try Generator.shared.generate(generationMode: .template("rxDataSourcesSectionType"), context: context, deleteGenerated: false)
        try Generator.shared.generate(generationMode: .template("storyboard-ViewController-TableView"), context: context, deleteGenerated: false)

        try generateHeadersAndFooters(context: context)

        if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(generationMode: .template("tableViewCell-RxSwift-TextField"), context: modifiedContext, deleteGenerated: false)
            }
        }

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithCollectionViewCombo(context: Context) throws {
        try Generator.shared.generate(generationMode: .template("viewController-RxSwift-CollectionView"), context: context, deleteGenerated: true)
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

        try generateViewCoordinator(context: context)
    }
}

// MARK: - Helpers

private extension TemplateCombo {
    func generateHeadersAndFooters(context: Context) throws {
        guard let name = context["name"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "name")
        }

        if context["sectionHeader"] != nil {
            try Generator.shared.generate(generationMode: .template("tableViewSectionHeader"), context: context, deleteGenerated: false)
        }

        if let header = context["tableViewHeader"] as? Bool, header {
            let modifiedContext = updateComboContext(context, name: name+"Header")
            try Generator.shared.generate(generationMode: .template("view"), context: modifiedContext, deleteGenerated: false)
        }

        if let footer = context["tableViewFooter"] as? Bool, footer {
            let modifiedContext = updateComboContext(context, name: name+"Footer")
            try Generator.shared.generate(generationMode: .template("view"), context: modifiedContext, deleteGenerated: false)
        }
    }

    func generateViewCoordinator(context: Context) throws {
        guard let coordinator = context["coordinator"] as? String else {
            return
        }

        guard let name = context["name"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "name")
        }

        var modifiedContext = updateComboContext(context, name: coordinator)
        modifiedContext["controllers"] = [name]
        try Generator.shared.generate(generationMode: .template("coordinator-Navigation"), context: modifiedContext, deleteGenerated: false)
    }
}
