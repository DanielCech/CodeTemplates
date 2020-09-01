//
//  SolidColorView.swift
//  HeraclesTrainer
//
//  Created by Dan Cech on 14.09.15.
//  Copyright (c) 2015 STRV. All rights reserved.
//

import UIKit

class SolidColorView: UIView {
    var solidColor: UIColor?

    override var backgroundColor: UIColor? {
        didSet {
            if let unwrappedSolidColor = solidColor {
                if (backgroundColor != nil) && (backgroundColor! != unwrappedSolidColor) {
                    backgroundColor = unwrappedSolidColor
                }
            }
        }
    }
}
