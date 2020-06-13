//
//  EventCollectionViewCell.swift
//  Harbor
//
//  Created by Daniel Cech on 5/19/20.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class EventCollectionViewCell: UICollectionViewCell, NibLoadableView {
    // MARK: IBOutlets
    @IBOutlet private var eventImageView: UIImageView!
    @IBOutlet private var eventIcon: UIImageView!
    @IBOutlet private var eventTitleLabel: UILabel!
    @IBOutlet private var eventStatusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        eventImageView.apply(style: .photoUploadCardView)
    }
}

extension EventCollectionViewCell {
    func set(
        with event: LibraryResponse.Event
    ) {
        // TODO: load from API

        eventTitleLabel.attributedText = event.name.styled(with: .dashboardActivityTitle)
        eventStatusLabel.attributedText = event.status.description().styled(with: .dashboardStatusText)
    }
}
