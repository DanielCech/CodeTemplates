//
//  LabelStyle.swift
//  Harbor
//
//  Created by Daniel Cech on 19/05/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

typealias LabelStyle = (UILabel) -> UILabel

/// Convenient way how to apply style to the view
extension UILabel {
    func apply(style: Stylesheet.Labels) {
        _ = (self |> style.style)
    }
}

func systemFontStyle(ofSize size: CGFloat, weight: UIFont.Weight) -> LabelStyle {
    return {
        $0.font = UIFont.systemFont(ofSize: size, weight: weight)
        return $0
    }
}

func fontStyle(_ font: UIFont) -> LabelStyle {
    return {
        $0.font = font
        return $0
    }
}

func textColorStyle(_ color: UIColor?) -> LabelStyle {
    return {
        $0.textColor = color
        return $0
    }
}

func textAlignmentStyle(_ textAlignment: NSTextAlignment) -> LabelStyle {
    return {
        $0.textAlignment = textAlignment
        return $0
    }
}

func numberOfLinesStyle(_ numberOfLines: Int) -> LabelStyle {
    return {
        $0.numberOfLines = numberOfLines
        return $0
    }
}

func lineBreakModeStyle(_ lineBreakMode: NSLineBreakMode) -> LabelStyle {
    return {
        $0.lineBreakMode = lineBreakMode
        return $0
    }
}
