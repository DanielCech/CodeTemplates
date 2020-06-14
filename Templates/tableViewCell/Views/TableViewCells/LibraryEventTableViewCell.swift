//
//  LibraryEventTableViewCell.swift
//  Harbor
//
//  Created by Daniel Cech on 5/18/20.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import Nuke
import RxCocoa
import RxSwift
import UIKit

/// Event cell in Dashboard screen
final class LibraryEventTableViewCell: UITableViewCell, NibLoadableView {
    // MARK: IBOutlets
    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var panelView: UIView!
    @IBOutlet private var eventImageView: UIImageView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var eventIcon: UIImageView!
    @IBOutlet private var eventTitleLabel: UILabel!
    @IBOutlet private var eventStateLabel: UILabel!
    @IBOutlet private var effectsView: UIVisualEffectView!
    @IBOutlet private var startButton: UIButton!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        setupStackViewSpaces()
    }

    func set(with event: LibraryResponse.Event) {
        // dispose to reset bindings
        disposeBag = DisposeBag()

        shadowView.apply(style: .roundedShadowPanel)
        panelView.apply(style: .roundedPanel)

        // TODO: setup from API
//        Nuke.loadImage(with: event.backgroundUrl, into: eventImageView)
//        Nuke.loadImage(with: event.iconUrl, into: eventIcon)

        eventTitleLabel.attributedText = event.name.styled(with: .dashboardEventName)
        eventStateLabel.attributedText = event.status.description().styled(with: .dashboardEventPercentage)
        startButton.isUserInteractionEnabled = false

        effectsView.apply(style: roundedStyle(radius: 20) <> clipToBoundsStyle(clip: true))
    }
}

private extension LibraryEventTableViewCell {
    func setupStackViewSpaces() {
        stackView.setCustomSpacing(8, after: eventIcon)
        stackView.setCustomSpacing(4, after: eventTitleLabel)
        stackView.setCustomSpacing(4, after: eventStateLabel)
    }
}
