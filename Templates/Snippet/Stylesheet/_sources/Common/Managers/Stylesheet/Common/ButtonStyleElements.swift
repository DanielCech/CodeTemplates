//
//  ButtonStyle.swift
//  Harbor
//
//  Created by Daniel Cech on 19/05/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

// USAGE:
// let redButtonStyle = roundedStyle(radius: 5) <> backgroundStyle(color: .red)
// let composedStyle = imageButtonStyle(image: UIImage()) <> aspectRatioStyle(size: CGSize())
// let button = UIButton(type: .custom)
// let newButton = button |> composedStyle

typealias ButtonStyle = (UIButton) -> UIButton

/// Convenient way how to apply style to the view
extension UIButton {
    func apply(style: Stylesheet.Buttons) {
        _ = (self |> style.style)
    }
}

func titleColorStyle(color: UIColor?) -> ButtonStyle {
    return {
        $0.setTitleColor(color, for: .normal)
        return $0
    }
}

func backgroundStyle(color: UIColor) -> ButtonStyle {
    return {
        $0.backgroundColor = color
        return $0
    }
}

func tintStyle(color: UIColor) -> ButtonStyle {
    return {
        $0.tintColor = color
        return $0
    }
}

func imageStyle(image: UIImage?) -> ButtonStyle {
    return {
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        $0.setImage(image, for: .normal)
        return $0
    }
}

func backgroundImageStyle(image: UIImage?) -> ButtonStyle {
    return {
        $0.setBackgroundImage(image, for: .normal)
        return $0
    }
}

func titleFontStyle(font: UIFont) -> ButtonStyle {
    return {
        $0.titleLabel?.font = font
        return $0
    }
}

func imagesInsetsStyle(insets: UIEdgeInsets) -> ButtonStyle {
    return {
        $0.imageEdgeInsets = insets
        return $0
    }
}

func titleInsetsStyle(insets: UIEdgeInsets) -> ButtonStyle {
    return {
        $0.titleEdgeInsets = insets
        return $0
    }
}

func titleStyle(titleStyle: Stylesheet.Labels) -> ButtonStyle {
    return {
        $0.titleLabel?.apply(style: titleStyle)
        return $0
    }
}

func attributedTextStyle(attributedText: NSAttributedString) -> ButtonStyle {
    return {
        $0.setAttributedTitle(attributedText, for: .normal)
        return $0
    }
}
