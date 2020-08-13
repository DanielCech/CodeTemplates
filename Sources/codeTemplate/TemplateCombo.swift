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
        let modifiedContext = Context(fromContext: context)
        modifiedContext.dictionary["name"] = name.camelCased()
        modifiedContext.dictionary["Name"] = name.pascalCased()
        return modifiedContext
    }
}

// MARK: - Factories

private extension TemplateCombo {
    func sceneViewControllerCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: context[.viewControllerTemplate] ?? "ViewController",
            storyboardTemplate: context[.storyboardTemplate] ?? "Storyboard-ViewController"
        )

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: context[.viewControllerTemplate] ?? "ViewController-RxSwift",
            storyboardTemplate: context[.storyboardTemplate] ?? "Storyboard-ViewController"
        )

        try generateTableViewCells(context: context, tableViewCellTemplate: "TableViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithTableViewCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: context[.viewControllerTemplate] ?? "ViewController-RxSwift-TableView",
            storyboardTemplate: context[.storyboardTemplate] ?? "Storyboard-ViewController-TableView"
        )

        try generateSectionType(context: context)

        try generateHeadersAndFooters(context: context)

        try generateTableViewCells(context: context, tableViewCellTemplate: "TableViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithFormTableViewCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: context[.viewControllerTemplate] ?? "ViewController-RxSwift-FormTableView",
            storyboardTemplate: context[.storyboardTemplate] ?? "Storyboard-ViewController-TableView"
        )

        try generateSectionType(context: context)

        try generateHeadersAndFooters(context: context)

        try generateTableViewCells(context: context, tableViewCellTemplate: "TableViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }

    func sceneViewControllerRxSwiftWithCollectionViewCombo(context: Context) throws {
        try generateViewController(
            context: context,
            viewControllerTemplate: context[.viewControllerTemplate] ?? "ViewController-RxSwift-CollectionView",
            storyboardTemplate: context[.storyboardTemplate] ?? "Storyboard-ViewController-CollectionView"
        )

        try generateSectionType(context: context)

        try generateCollectionViewCells(context: context, collectionViewCellTemplate: "CollectionViewCell-RxSwift")

        try generateViewCoordinator(context: context)
    }
}

// MARK: - Helpers

private extension TemplateCombo {
    func generateViewController(
        context: Context,
        viewControllerTemplate: Template,
        storyboardTemplate: Template
    ) throws {
        try Generator.shared.generate(context: context, generationMode: .template(viewControllerTemplate), deleteGenerate: true)
        try Generator.shared.generate(context: context, generationMode: .template("ViewModelAssembly"), deleteGenerate: false)
        try Generator.shared.generate(context: context, generationMode: .template(storyboardTemplate), deleteGenerate: false)
    }

    func generateSectionType(context: Context) throws {
        try Generator.shared.generate(context: context, generationMode: .template("RxDataSourcesSectionType"), deleteGenerate: false)
    }

    func generateHeadersAndFooters(context: Context) throws {
        let name = context.stringValue(.name)

        if context[.tableSectionHeaders] != nil {
            try Generator.shared.generate(context: context, generationMode: .template("TableViewSectionHeader"), deleteGenerate: false)
        }

        if context[.tableViewHeader] == true {
            let modifiedContext = updateComboContext(context, name: name+"Header")
            try Generator.shared.generate(context: modifiedContext, generationMode: .template("View"), deleteGenerate: false)
        }

        if context[.tableViewFooter] == true {
            let modifiedContext = updateComboContext(context, name: name+"Footer")
            try Generator.shared.generate(context: modifiedContext, generationMode: .template("View"), deleteGenerate: false)
        }
    }

    func generateTableViewCells(context: Context, tableViewCellTemplate: Template) throws {
        if let unwrappedNewCells = context[.newTableViewCells] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(context: modifiedContext, generationMode: .template(tableViewCellTemplate), deleteGenerate: false)
            }
        }
    }

    func generateCollectionViewCells(context: Context, collectionViewCellTemplate: Template) throws {
        if let unwrappedNewCells = context[.newCollectionViewCells] {
            for cell in unwrappedNewCells {
                let modifiedContext = updateComboContext(context, name: cell)
                try Generator.shared.generate(context: modifiedContext,generationMode: .template(collectionViewCellTemplate), deleteGenerate: false)
            }
        }
    }

    func generateViewCoordinator(context: Context) throws {
        guard let coordinator = context[.coordinator] else { return }

        let modifiedContext = updateComboContext(context, name: coordinator) // TODO: check the name and suffix Coordinator, Coordinating
        modifiedContext[.controllers] = [context.stringValue(.name)]
        try Generator.shared.generate(context: modifiedContext,generationMode: .template("Coordinator-Navigation"), deleteGenerate: false)
    }
}
