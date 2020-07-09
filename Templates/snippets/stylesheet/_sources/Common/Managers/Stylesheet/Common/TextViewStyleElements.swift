//
//  TextViewElements.swift
//  Harbor
//
//  Created by Tomas Cejka on 5/29/20.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

typealias TextViewStyle = (UITextView) -> UITextView

/// Convenient way how to apply style to the view
extension UITextView {
    func apply(style: Stylesheet.TextViews) {
        _ = (self |> style.style)
    }
}

func fontStyle(_ font: UIFont) -> TextViewStyle {
    return {
        $0.font = font
        return $0
    }
}

func textColorStyle(_ color: UIColor) -> TextViewStyle {
    return {
        $0.textColor = color
        return $0
    }
}

func textAlignmentStyle(_ textAlignment: NSTextAlignment) -> TextViewStyle {
    return {
        $0.textAlignment = textAlignment
        return $0
    }
}

func dissabledStyle() -> TextViewStyle {
    return {
        $0.isEditable = false
        return $0
    }
}

func linkTextAttributesStyle(_ color: UIColor) -> TextViewStyle {
    return {
        $0.linkTextAttributes = [.foregroundColor: color]
        return $0
    }
}
