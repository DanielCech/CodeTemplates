//
//  EmergencyContactsViewModel.swift
//  Harbor
//
//  Created by Daniel Cech on 14/06/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias EmergencyContactsSectionModel = SectionModel<String?, EmergencyContactsSection>

final class EmergencyContactsViewModel: ViewModelType {
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

extension EmergencyContactsViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
    }

    struct Output {
        let emergencyContactsSections: Driver<[EmergencyContactsSectionModel]>
    }

    func transform(input: EmergencyContactsViewModel.Input) -> EmergencyContactsViewModel.Output {
        let emergencyContactsOutput = input.viewWillAppear
            .flatMap {
                self.apiService.fetchEmergencyContacts()
            }
            .map { response -> [EmergencyContactsSectionModel] in
                let sections: [EmergencyContactsSectionModel] = [
                    SectionModel(model: nil, items: [.header]),
                    SectionModel(model: R.string.localizable.emergencyContactsRecommended(), items: [.eventList(response.recommended)]),
                    SectionModel(model: R.string.localizable.emergencyContactsForFamilies(), items: response.forFamilies.map { .event($0) }),
                    SectionModel(model: R.string.localizable.emergencyContactsOtherRisks(), items: response.otherRisks.map { .event($0) }),
                ]
                return sections
            }
            .asDriverLogError()

        return Output(emergencyContactsSections: emergencyContactsOutput)
    }
}
