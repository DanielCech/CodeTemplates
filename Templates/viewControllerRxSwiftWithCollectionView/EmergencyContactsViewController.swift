//
//  EmergencyContactsViewController.swift
//  Harbor
//
//  Created by Daniel Cech on 5/11/20.
//  Copyright © 2020 STRV. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class EmergencyContactsViewController: UIViewController, ViewModelContaining {
    // MARK: IBOutlets
    @IBOutlet private var fakeNavbar: UIView!
    @IBOutlet private var fakeNavbarTitleLabel: UILabel!
    @IBOutlet private var fakeNavbarTopConstraint: NSLayoutConstraint!
    @IBOutlet private var emergencyContactsTableView: UITableView!

    // MARK: Public Properties

    // swiftlint:disable:next implicitly_unwrapped_optional
    weak var coordinator: EmergencyContactsNavigationCoordinating!

    // swiftlint:disable:next implicitly_unwrapped_optional
    var viewModel: EmergencyContactsViewModel!
    var disposeBag: DisposeBag = DisposeBag()

    // MARK: Private Properties
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<EmergencyContactsSectionModel>(configureCell: { _, tableView, indexPath, item -> UITableViewCell in
        switch item {
        case .header:
            let cell: LibraryHeaderTableViewCell = tableView.dequeueReusableCell(for: indexPath)
//            cell.set(with: text, eventCount: eventCount)
            return cell
        case let .eventList(events):
            let cell: LibraryEventListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.set(with: events, selectedEvent: { [weak self] event in
                self?.showEvent(event)
            })
            return cell
        case let .event(event):
            let cell: LibraryEventTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.set(with: event)
            return cell
        }
        })

    // MARK: Lifecycle

    deinit {
        print("Deinit \(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
}

// MARK: - Table headers

extension EmergencyContactsViewController: UITableViewDelegate {
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle = dataSource.sectionModels[section].model else {
            return nil
        }

        let headerView: SimpleSectionHeader = emergencyContactsTableView.dequeueReusableHeaderFooterView()
        headerView.setup(title: sectionTitle)
        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard dataSource.sectionModels[section].model != nil else {
            return 0
        }

        return 52
    }
}

// MARK: - Binding

extension EmergencyContactsViewController {
    func bindToView() {
        emergencyContactsTableView.rx.contentOffset.map { $0.y > 100 }.distinctUntilChanged()
            .withUnretained(self)
            .bind(onNext: { _, scrolled in
                self.fakeNavbarTopConstraint.constant = scrolled ? 0 : -92
                let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: {
                    self.view.layoutIfNeeded()
                    })

                animator.startAnimation()
                })
            .disposed(by: disposeBag)

        emergencyContactsTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    func bindToViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
        let input = EmergencyContactsViewModel.Input(
            viewWillAppear: viewWillAppear
        )
        let output = viewModel.transform(input: input)
        output.emergencyContactsSections.drive(emergencyContactsTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

    func bindToCoordinator() {
        emergencyContactsTableView.rx.modelSelected(EmergencyContactsSection.self)
            .bind(onNext: { [weak self] section in
                switch section {
                case let .event(event):
                    self?.showEvent(event)
                default:
                    break
                }

            }).disposed(by: disposeBag)
    }
}

// MARK: - Private Methods

private extension EmergencyContactsViewController {
    func setupView() {
        setupIBOutlets()
        bindToView()
        bindToViewModel()
        bindToCoordinator()
    }

    func setupIBOutlets() {
        fakeNavbarTitleLabel.attributedText = R.string.localizable.libraryTitle().styled(with: .dashboardActivityTitle)
        fakeNavbar.apply(style: .shadow)

        emergencyContactsTableView.separatorStyle = .none
        emergencyContactsTableView.rowHeight = UITableView.automaticDimension
        emergencyContactsTableView.register(LibraryHeaderTableViewCell.self)
        emergencyContactsTableView.register(LibraryEventTableViewCell.self)
        emergencyContactsTableView.register(LibraryEventListTableViewCell.self)
        emergencyContactsTableView.registerHeaderFooterView(SimpleSectionHeader.self)
    }

    func showEvent(_ event: LibraryResponse.Event) {
        // TODO: this is temporary conversion between event types. We are using two mocked API response types for event. It will be unified with changes on API side.
        let dashboardEvent = DashboardResponse.Event(id: event.id, name: event.name, iconUrl: event.iconUrl, backgroundUrl: event.backgroundUrl, progressPercentage: 0)

        coordinator.showEvent(dashboardEvent)
    }
}
