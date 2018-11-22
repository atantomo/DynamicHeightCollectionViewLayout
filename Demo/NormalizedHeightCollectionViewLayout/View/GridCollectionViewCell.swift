//
//  GridCollectionViewCell.swift
//  NormalizedHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/08/14.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {

    @IBOutlet var container: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var updateButton: UIButton!

    @IBOutlet var imageAspectConstraint: NSLayoutConstraint!

    @IBOutlet var verticalConstraints: [NSLayoutConstraint]!
    @IBOutlet var topLabelSideConstraints: [NSLayoutConstraint]!
    @IBOutlet var leftRightLabelsSideConstraints: [NSLayoutConstraint]!

    lazy var verticalPadding: CGFloat = { return self.verticalConstraints.getConstantsSum() }()
    lazy var topLabelSidePadding: CGFloat = { return self.topLabelSideConstraints.getConstantsSum() }()
    lazy var leftRightLabelsSidePadding: CGFloat = { return self.leftRightLabelsSideConstraints.getConstantsSum() }()

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                container.backgroundColor = Resources.Color.highlightedCellBackground
            } else {
                container.backgroundColor = Resources.Color.normalCellBackground
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                container.backgroundColor = Resources.Color.highlightedCellBackground
            } else {
                container.backgroundColor = Resources.Color.normalCellBackground
            }
        }
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Resources.NotificationName.deleteCell, object: deleteButton)
    }

    @IBAction func updateButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Resources.NotificationName.updateCell, object: updateButton)
    }
}

extension GridCollectionViewCell: HeightCalculable {

    func heightForWidth<T>(width: CGFloat, model: T) -> CGFloat {
        guard let model = model as? CellModel else {
            return 0.0
        }
        let imageHeight = width * imageAspectConstraint.multiplier

        let topLabelWidth = width - topLabelSidePadding
        let topLabelHeight = TextHeightCalculator.calculate(for:
            (text: model.topText, font: topLabel.font, width: topLabelWidth)
        )

        let leftRightLabelsWidth = (width - leftRightLabelsSidePadding) / 2
        let leftRightLabelsHeight = TextHeightCalculator.calculateMax(for: [
            (text: model.leftText, font: leftLabel.font, width: leftRightLabelsWidth),
            (text: model.rightText, font: rightLabel.font, width: leftRightLabelsWidth)
            ])

        let sum = imageHeight + topLabelHeight + leftRightLabelsHeight + verticalPadding
        return sum
    }

}
