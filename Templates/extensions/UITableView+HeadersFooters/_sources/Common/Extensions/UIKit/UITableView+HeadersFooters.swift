//
//  UITableView+HeadersFooters.swift
//  Harbor
//
//  Created by Daniel Cech on 14/07/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

extension UITableView {
    func setTableHeader(header: UIView, height: CGFloat) {
        header.translatesAutoresizingMaskIntoConstraints = false
        tableHeaderView = wrapperView(for: header, height: height)
    }

    func setTableFooter(footer: UIView, height: CGFloat) {
        footer.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView = wrapperView(for: footer, height: height)
    }

    private func wrapperView(for view: UIView, height: CGFloat) -> UIView {
        let wrapperView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        wrapperView.autoresizingMask = [.flexibleWidth]
        wrapperView.addSubview(view)
        view.fillContainer()
        return wrapperView
    }
}
