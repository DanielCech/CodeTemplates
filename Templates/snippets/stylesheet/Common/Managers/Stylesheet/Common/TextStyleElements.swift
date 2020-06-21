//
//  TextStyle.swift
//  Harbor
//
//  Created by Daniel Cech on 19/05/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import BonMot
import Foundation

typealias TextStyle = (StringStyle) -> StringStyle

extension String {
    func styled(with style: Stylesheet.TextStyles) -> NSAttributedString {
        return styled(with: stringStyle(textStyle: style))
    }
}

func stringStyle(textStyle: Stylesheet.TextStyles) -> StringStyle {
    return StringStyle() |> textStyle.style
}

func fontStyle(_ font: UIFont) -> TextStyle {
    return {
        $0.byAdding(.font(font))
    }
}

func lineBreakModeStyle(_ lineBreakMode: NSLineBreakMode) -> TextStyle {
    return {
        $0.byAdding(.lineBreakMode(lineBreakMode))
    }
}

func backgroundColorStyle(_ color: UIColor) -> TextStyle {
    return {
        $0.byAdding(.backgroundColor(color))
    }
}

func colorStyle(_ color: UIColor?) -> TextStyle {
    return {
        if let color = color {
            return $0.byAdding(.color(color))
        }
        return $0
    }
}

func underlineStyle(_ underlineStyle: NSUnderlineStyle, color: UIColor) -> TextStyle {
    return {
        $0.byAdding(.underline(underlineStyle, color))
    }
}

func strikethroughStyle(_ underlineStyle: NSUnderlineStyle, color: UIColor) -> TextStyle {
    return {
        $0.byAdding(.strikethrough(underlineStyle, color))
    }
}

func alignmentStyle(_ textAlignment: NSTextAlignment) -> TextStyle {
    return {
        $0.byAdding(.alignment(textAlignment))
    }
}

func lineSpacingStyle(_ spacing: CGFloat) -> TextStyle {
    return {
        $0.byAdding(.lineSpacing(spacing))
    }
}

func paragraphLineHeightMultipleStyle(_ multiple: CGFloat) -> TextStyle {
    return {
        $0.byAdding(.lineHeightMultiple(multiple))
    }
}

func linkStyle(_ textStyle: StringStyle) -> TextStyle {
    return {
        $0.byAdding(.xmlRules([.style("link", textStyle)]))
    }
}
