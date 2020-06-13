//
//  LibraryEventListTableViewCell.swift
//  Harbor
//
//  Created by Daniel Cech on 5/18/20.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class LibraryEventListTableViewCell: UITableViewCell, NibLoadableView {
    // MARK: IBOutlets
    @IBOutlet private var eventsCollectionView: UICollectionView! {
        didSet {
            eventsCollectionView.register(EventCollectionViewCell.self)
            eventsCollectionView.showsHorizontalScrollIndicator = false
        }
    }

    private var disposeBag = DisposeBag()
    private let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, LibraryResponse.Event>>(configureCell: { _, collection, indexPath, item in
        let cell: EventCollectionViewCell = collection.dequeueReusableCell(for: indexPath)
        cell.set(with: item)
        return cell
    })

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func set(
        with events: [LibraryResponse.Event],
        selectedEvent: @escaping VoidClosure<LibraryResponse.Event>
    ) {
        // dispose to reset bindings
        disposeBag = DisposeBag()
        let sectionModelsObservable = Observable.just([
            SectionModel(model: "", items: events)
        ])

        eventsCollectionView.rx
            .modelSelected(LibraryResponse.Event.self)
            .subscribeNext { eventItem -> Void in
                selectedEvent(eventItem)
            }
            .disposed(by: disposeBag)

        sectionModelsObservable.bind(to: eventsCollectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}
