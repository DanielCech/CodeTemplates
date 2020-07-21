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
    case sceneViewControllerRxSwift = "Scene-ViewController-RxSwift"
    case sceneViewControllerRxSwiftWithTableView = "Scene-ViewController-RxSwift-TableView"
    case sceneViewControllerRxSwiftWithFormTableView = "Scene-ViewController-RxSwift-FormTableView"
    case sceneViewControllerRxSwiftWithCollectionView = "Scene-ViewController-RxSwift-CollectionView"

    func perform(context: Context) throws {
        switch self {
        case .scene:
            try sceneViewControllerCombo(context: context)

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
    func sceneViewControllerCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: "ViewController",
            storyboardTemplate: "Storyboard-ViewController",
            generateSectionType: false
        )

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: "ViewController-RxSwift",
            storyboardTemplate: "Storyboard-ViewController"
        )

        try generateTableViewCells(context: context, tableViewCellTemplate: "TableViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithTableViewCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: "ViewController-RxSwift-TableView",
            storyboardTemplate: "Storyboard-ViewController-TableView"
        )

        try generateHeadersAndFooters(context: context)

        try generateTableViewCells(context: context, tableViewCellTemplate: "TableViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithFormTableViewCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: "ViewController-RxSwift-FormTableView",
            storyboardTemplate: "Storyboard-ViewController-TableView"
        )

        try generateHeadersAndFooters(context: context)

        try generateTableViewCells(context: context, tableViewCellTemplate: "TableViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithCollectionViewCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: "ViewController-RxSwift-CollectionView",
            storyboardTemplate: "Storyboard-ViewController-CollectionView"
        )

        try generateCollectionViewCells(context: context, collectionViewCellTemplate: "CollectionViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }
}

// MARK: - Helpers

private extension TemplateCombo {
    func generateViewController(
        context: Context,
        viewControllerTemplate: Template,
        storyboardTemplate: Template,
        generateSectionType: Bool = true
    ) throws {
        try Generator.shared.generate(generationMode: .template(viewControllerTemplate), context: context, deleteGenerated: true)
        try Generator.shared.generate(generationMode: .template("ViewModelAssembly"), context: context, deleteGenerated: false)

        if generateSectionType {
            try Generator.shared.generate(generationMode: .template("RxDataSourcesSectionType"), context: context, deleteGenerated: false)
        }

        try Generator.shared.generate(generationMode: .template(storyboardTemplate), context: context, deleteGenerated: false)
    }

    func generateHeadersAndFooters(context: Context) throws {
        guard let name = context["name"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "name")
        }

        if context["sectionHeader"] != nil {
            try Generator.shared.generate(generationMode: .template("TableViewSectionHeader"), context: context, deleteGenerated: false)
        }

        if let header = context["tableViewHeader"] as? Bool, header {
            let modifiedContext = updateComboContext(context, name: name+"Header")
            try Generator.shared.generate(generationMode: .template("View"), context: modifiedContext, deleteGenerated: false)
        }

        if let footer = context["tableViewFooter"] as? Bool, footer {
            let modifiedContext = updateComboContext(context, name: name+"Footer")
            try Generator.shared.generate(generationMode: .template("View"), context: modifiedContext, deleteGenerated: false)
        }
    }

    func generateTableViewCells(context: Context, tableViewCellTemplate: Template) throws {
        if let unwrappedNewCells = context["newTableViewCells"] as? [String] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(generationMode: .template(tableViewCellTemplate), context: modifiedContext, deleteGenerated: false)
            }
        }
    }

    func generateCollectionViewCells(context: Context, collectionViewCellTemplate: Template) throws {
        if let unwrappedNewCells = context["newCollectionViewCells"] as? [String] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(generationMode: .template(collectionViewCellTemplate), context: modifiedContext, deleteGenerated: false)
            }
        }
    }

    func generateViewCoordinator(context: Context) throws {
        guard let coordinator = context["Coordinator"] as? String else {
            return
        }

        guard let name = context["name"] as? String else {
            throw CodeTemplateError.parameterNotSpecified(message: "name")
        }

        var modifiedContext = updateComboContext(context, name: coordinator)
        modifiedContext["controllers"] = [name]
        try Generator.shared.generate(generationMode: .template("Coordinator-Navigation"), context: modifiedContext, deleteGenerated: false)
    }
}
