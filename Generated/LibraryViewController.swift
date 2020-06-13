//
//  LibraryViewController.swift
//  Harbor
//
//  Created by Tomas Cejka on 5/11/20.
//  Copyright © 2020 STRV. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class LibraryViewController: UIViewController, ViewModelContaining {
    // MARK: IBOutlets
    @IBOutlet private var fakeNavbar: UIView!
    @IBOutlet private var fakeNavbarTitleLabel: UILabel!
    @IBOutlet private var fakeNavbarTopConstraint: NSLayoutConstraint!
    @IBOutlet private var libraryTableView: UITableView!

    // MARK: Public Properties

    // swiftlint:disable:next implicitly_unwrapped_optional
    weak var coordinator: LibraryNavigationCoordinating!

    // swiftlint:disable:next implicitly_unwrapped_optional
    var viewModel: LibraryViewModel!
    var disposeBag: DisposeBag = DisposeBag()

    // MARK: Private Properties
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<LibrarySectionModel>(configureCell: { _, tableView, indexPath, item -> UITableViewCell in
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

extension LibraryViewController: UITableViewDelegate {
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle = dataSource.sectionModels[section].model else {
            return nil
        }

        let headerView: SimpleSectionHeader = libraryTableView.dequeueReusableHeaderFooterView()
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

extension LibraryViewController {
    func bindToView() {
        libraryTableView.rx.contentOffset.map { $0.y > 100 }.distinctUntilChanged()
            .withUnretained(self)
            .bind(onNext: { _, scrolled in
                self.fakeNavbarTopConstraint.constant = scrolled ? 0 : -92
                let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut, animations: {
                    self.view.layoutIfNeeded()
                    })

                animator.startAnimation()
                })
            .disposed(by: disposeBag)

        libraryTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    func bindToViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
        let input = LibraryViewModel.Input(
            viewWillAppear: viewWillAppear
        )
        let output = viewModel.transform(input: input)
        output.librarySections.drive(libraryTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

    func bindToCoordinator() {
        libraryTableView.rx.modelSelected(LibrarySection.self)
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

private extension LibraryViewController {
    func setupView() {
        setupIBOutlets()
        bindToView()
        bindToViewModel()
        bindToCoordinator()
    }

    func setupIBOutlets() {
        fakeNavbarTitleLabel.attributedText = R.string.localizable.libraryTitle().styled(with: .dashboardActivityTitle)
        fakeNavbar.apply(style: .shadow)

        libraryTableView.separatorStyle = .none
        libraryTableView.rowHeight = UITableView.automaticDimension
        libraryTableView.register(LibraryHeaderTableViewCell.self)
        libraryTableView.register(LibraryEventTableViewCell.self)
        libraryTableView.register(LibraryEventListTableViewCell.self)
        libraryTableView.registerHeaderFooterView(SimpleSectionHeader.self)
    }

    func showEvent(_ event: LibraryResponse.Event) {
        // TODO: this is temporary conversion between event types. We are using two mocked API response types for event. It will be unified with changes on API side.
        let dashboardEvent = DashboardResponse.Event(id: event.id, name: event.name, iconUrl: event.iconUrl, backgroundUrl: event.backgroundUrl, progressPercentage: 0)

        coordinator.showEvent(dashboardEvent)
    }
}
