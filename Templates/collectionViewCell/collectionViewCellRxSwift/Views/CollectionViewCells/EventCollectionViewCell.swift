//
//  {{fileName}}
//  {{projectName}}
//
//  Created by {{author}} on {{date}}.
//  {{copyright}}
//

import RxCocoa
import RxSwift
import UIKit

final class {{Screen}}{{Name}}ViewCell: UICollectionViewCell, NibLoadableView {
    // MARK: IBOutlets

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
    }
}

extension {{Screen}}{{Name}}ViewCell {
    func setup() {

    }
}
