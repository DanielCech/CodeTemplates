//
//  StyleComposition.swift
//  Harbor
//
//  Created by Daniel Cech on 19/05/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

typealias Style<A> = (A) -> A

// Aplying style to element
precedencegroup ForwardApplication {
    associativity: left
}

infix operator |> : ForwardApplication
func |> <A>(element: A, style: Style<A>) -> A {
    return style(element)
}

// Style composition
precedencegroup FunctionalComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator <> : FunctionalComposition
func <> <A>(function1: @escaping (A) -> A, function2: @escaping (A) -> A) -> (A) -> A {
    return { value -> A in
        function2(function1(value))
    }
}
