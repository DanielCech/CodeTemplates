//
//  ViewModelType.swift
//  Harbor
//
//  Created by Abel Osorio on 5/18/19.
//  Copyright © 2019 STRV. All rights reserved.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
