//
//  LibraryNavigationCoordinator.swift
//  Harbor
//
//  Created by Tomas Cejka on 5/10/20.
//  Copyright © 2020 STRV. All rights reserved.
//

import Swinject
import UIKit

final class LibraryNavigationCoordinator {
    // MARK: Public properties
    var childCoordinators = [Coordinator]()
    let assembler: Assembler

    let navigationController: UINavigationController

    var dismissCallback: VoidClosure<Coordinator>?

    // MARK: Lifecycle

    deinit {
        print("Deinit \(self)")
    }

    init(navigationController: UINavigationController, assembler: Assembler) {
        self.navigationController = navigationController
        self.assembler = assembler
    }
}

// MARK: - LibraryNavigationCoordinatoring

extension LibraryNavigationCoordinator: LibraryNavigationCoordinating {
    func showActivity() {}

    func start() {
        navigationController.pushViewController(
            makeLibraryViewController(),
            animated: false
        )
    }

    func showEvent(_ event: DashboardResponse.Event) {
        let eventController = makeEventViewController(event: event)
        navigationController.pushViewController(eventController, animated: true)
    }
}

// MARK: - Factories

// Extension is internal to be accessible from test target
internal extension LibraryNavigationCoordinator {
    func makeLibraryViewController() -> LibraryViewController {
        let viewController = R.storyboard.libraryViewController.instantiateInitialViewController(
            viewModel: resolve(LibraryViewModel.self)
        )

        viewController.coordinator = self

        return viewController
    }
}
