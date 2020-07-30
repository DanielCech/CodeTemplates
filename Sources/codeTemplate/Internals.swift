//
//  Internals.swift
//  codeTemplate
//
//  Created by Daniel Cech on 30/07/2020.
//

import Foundation

enum Internals {
    static let genericTypes = [
        "Any",
        "AnyObject"
    ]
    
    static let foundationTypes = [
        "AffineTransform",
        "NSAffineTransform",
        "Array",
        "NSArray",
        "Calendar",
        "NSCalendar",
        "CharacterSet",
        "NSCharacterSet",
        "Data",
        "NSData",
        "DateComponents",
        "NSDateComponents",
        "DateInterval",
        "NSDateInterval",
        "Date",
        "NSDate",
        "Decimal",
        "NSDecimalNumber",
        "Dictionary",
        "NSDictionary",
        "IndexPath",
        "NSIndexPath",
        "IndexSet",
        "NSIndexSet",
        "Locale",
        "NSLocale",
        "Measurement",
        "NSMeasurement",
        "Notification",
        "NSNotification",
        "Int",
        "Float",
        "NSNumber",
        "PersonNameComponents",
        "NSPersonNameComponents",
        "Set",
        "NSSet",
        "String",
        "NSString",
        "TimeZone",
        "NSTimeZone",
        "URL",
        "NSURL",
        "URLComponents",
        "NSURLComponents",
        "URLQueryItem",
        "NSURLQueryItem",
        "URLRequest",
        "NSURLRequest",
        "UUID"
    ]

    static let uiKitTypes = [
        "UIView",
        "UIStackView",
        "UIScrollView",
        "UIActivityIndicatorView",
        "UIImageView",
        "UIPickerView",
        "UIProgressView",
        "UIWebView",
        "UIControl",
        "UIButton",
        "UIColorWell",
        "UIDatePicker",
        "UIPageControl",
        "UISegmentedControl",
        "UISlider",
        "UIStepper",
        "UISwitch",
        "UILabel",
        "UITextField",
        "UITextView",
        "UISearchTextField",
        "UISearchToken",
        "UIVisualEffect",
        "UIVisualEffectView",
        "UIVibrancyEffect",
        "UIBlurEffect",
        "UIBarItem",
        "UIBarButtonItem",
        "UIBarButtonItemGroup",
        "UINavigationBar",
        "UISearchBar",
        "UIToolbar",
        "UITabBar",
        "UITabBarItem",
        "UILargeContentViewerInteraction",
        "UIOffset",
        "UIEdgeInsets",
        "UIAxis",
        "NSDirectionalEdgeInsets",
        "NSDirectionalRectEdge",
        "UIDirectionalRectEdge"
    ]
    
    static let systemTypes: Set<String> = Set(genericTypes + foundationTypes + uiKitTypes)
    
    static let systemFrameworks = ["Foundation", "UIKit"]
}