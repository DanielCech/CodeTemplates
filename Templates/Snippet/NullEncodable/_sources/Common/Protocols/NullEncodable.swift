//
//  NullEncodable.swift
//  Harbor
//
//  Created by Tomas Cejka on 7/3/20.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import Foundation

@propertyWrapper
struct NullEncodable<T>: Codable where T: Codable {
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case let .some(value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(T.self)
    }
}
