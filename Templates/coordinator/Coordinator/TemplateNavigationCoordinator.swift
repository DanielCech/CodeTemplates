//
//  EmergencyContactsNavigationCoordinator.swift
//  Harbor
//
//  Created by Daniel Cech on 5/10/20.
//  Copyright © 2020 STRV. All rights reserved.
//

import Swinject
import UIKit

final class EmergencyContactsNavigationCoordinator {
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

extension EmergencyContactsNavigationCoordinator: LibraryNavigationCoordinating {
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
internal extension EmergencyContactsNavigationCoordinator {
    func makeLibraryViewController() -> LibraryViewController {
        let viewController = R.storyboard.libraryViewController.instantiateInitialViewController(
            viewModel: resolve(LibraryViewModel.self)
        )

        viewController.coordinator = self

        return viewController
    }
}
