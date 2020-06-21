//
//  ViewStyleElements.swift
//  Harbor
//
//  Created by Daniel Cech on 19/05/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

typealias ViewStyle = (UIView) -> UIView

/// Convenient way how to apply style to the view

extension UIView {
    func apply(style: Stylesheet.Views) {
        apply(style: style.style)
    }

    func apply(style: Style<UIView>) {
        _ = (self |> style)
    }
}

func autolayoutStyle<V: UIView>() -> Style<V> {
    return {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }
}

func clipToBoundsStyle<V: UIView>(clip: Bool) -> Style<V> {
    return {
        $0.clipsToBounds = clip
        return $0
    }
}

func aspectRatioStyle<V: UIView>(size: CGSize) -> Style<V> {
    return {
        $0.widthAnchor
            .constraint(equalTo: $0.heightAnchor, multiplier: size.width / size.height)
            .isActive = true
        return $0
    }
}

func borderStyle<V: UIView>(color: UIColor?, width: CGFloat) -> Style<V> {
    return {
        $0.layer.borderColor = color?.cgColor
        $0.layer.borderWidth = width
        return $0
    }
}

func shadowStyle<V: UIView>(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) -> Style<V> {
    return {
        $0.layer.shadowColor = color.cgColor
        $0.layer.shadowOffset = offset
        $0.layer.shadowRadius = radius
        $0.layer.shadowOpacity = opacity
        $0.layer.masksToBounds = false
        return $0
    }
}

func implicitAspectRatioStyle<V: UIView>() -> Style<V> {
    return {
        aspectRatioStyle(size: $0.frame.size)($0)
    }
}

func roundedStyle<V: UIView>(radius: CGFloat) -> Style<V> {
    return {
        $0.layer.cornerRadius = radius
        return $0
    }
}

func backgroundColorStyle<V: UIView>(backgroundColor: UIColor?) -> Style<V> {
    return {
        $0.backgroundColor = backgroundColor
        return $0
    }
}
