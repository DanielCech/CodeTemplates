//
//  LibraryHeaderTableViewCell.swift
//  Harbor
//
//  Created by Daniel Cech on 09/06/2020.
//  Copyright © 2020 25MP Corp. All rights reserved.
//

import UIKit

final class LibraryHeaderTableViewCell: UITableViewCell, NibLoadableView {
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        titleLabel.attributedText = R.string.localizable.libraryTitle().styled(with: .libraryHeader)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
