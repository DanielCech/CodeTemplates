//
//  TextFieldStyleElements.swift
//  Harbor
//
//  Created by Daniel Cech on 19/05/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

typealias TextFieldStyle = (UITextField) -> UITextField

/// Convenient way how to apply style to the view
extension UITextField {
    func apply(style: Stylesheet.TextFields) {
        _ = (self |> style.style)
    }
}

func isSecureTextEntryStyle(_ secure: Bool) -> TextFieldStyle {
    return {
        $0.isSecureTextEntry = secure
        return $0
    }
}

func placeholderStyle(_ placeholder: String) -> TextFieldStyle {
    return {
        $0.placeholder = placeholder
        return $0
    }
}

func keyboardTypeStyle(_ keyboardType: UIKeyboardType) -> TextFieldStyle {
    return {
        $0.keyboardType = keyboardType
        return $0
    }
}

func autocapitalizationStyle(_ autocapitalizationType: UITextAutocapitalizationType) -> TextFieldStyle {
    return {
        $0.autocapitalizationType = autocapitalizationType
        return $0
    }
}

func borderStyle(_ borderStyle: UITextField.BorderStyle) -> TextFieldStyle {
    return {
        $0.borderStyle = borderStyle
        return $0
    }
}

func bottomBorder(_ color: UIColor) -> TextFieldStyle {
    return {
        let uiView = UIView()
        uiView.apply(style: .backgroundColor(color))
        $0.addSubview(uiView)
        uiView.leadingAnchor.constraint(equalTo: $0.leadingAnchor).isActive = true
        uiView.trailingAnchor.constraint(equalTo: $0.trailingAnchor).isActive = true
        uiView.bottomAnchor.constraint(equalTo: $0.bottomAnchor).isActive = true
        uiView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return $0
    }
}

func textColorStyle(_ color: UIColor?) -> TextFieldStyle {
    return {
        $0.textColor = color
        return $0
    }
}

func fontStyle(_ font: UIFont) -> TextFieldStyle {
    return {
        $0.font = font
        return $0
    }
}

func attributedPlaceholder(_ string: NSAttributedString) -> TextFieldStyle {
    return {
        $0.attributedPlaceholder = string
        return $0
    }
}

func rightViewModeStyle(_ mode: UITextField.ViewMode) -> TextFieldStyle {
    return {
        $0.rightViewMode = mode
        return $0
    }
}
