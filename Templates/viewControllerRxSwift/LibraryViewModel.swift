//
//  LibraryViewModel.swift
//  Harbor
//
//  Created by Tomas Cejka on 5/11/20.
//  Copyright © 2020 STRV. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias LibrarySectionModel = SectionModel<String?, LibrarySection>

final class LibraryViewModel: ViewModelType {
    // MARK: Private properties
    private let apiService: AppServicing

    // MARK: Lifecycle

    deinit {
        print("Deinit \(self)")
    }

    init(apiService: AppServicing) {
        self.apiService = apiService
    }
}

// MARK: - Input / output transformation

extension LibraryViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
    }

    struct Output {
        let librarySections: Driver<[LibrarySectionModel]>
    }

    func transform(input: LibraryViewModel.Input) -> LibraryViewModel.Output {
        let libraryOutput = input.viewWillAppear
            .flatMap {
                self.apiService.fetchLibrary()
            }
            .map { response -> [LibrarySectionModel] in
                let sections: [LibrarySectionModel] = [
                    SectionModel(model: nil, items: [.header]),
//                    SectionModel(model: (), items: [.title(R.string.localizable.libraryRecommended())]),
                    SectionModel(model: R.string.localizable.libraryRecommended(), items: [.eventList(response.recommended)]),
//                    SectionModel(model: (), items: [.title(R.string.localizable.libraryForFamilies())]),
                    SectionModel(model: R.string.localizable.libraryForFamilies(), items: response.forFamilies.map { .event($0) }),
//                    SectionModel(model: (), items: [.title(R.string.localizable.libraryOtherRisks())]),
                    SectionModel(model: R.string.localizable.libraryOtherRisks(), items: response.otherRisks.map { .event($0) }),
                ]
                return sections
            }
            .asDriverLogError()

        return Output(librarySections: libraryOutput)
    }
}
