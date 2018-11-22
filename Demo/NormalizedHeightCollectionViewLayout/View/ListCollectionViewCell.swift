//
//  ListCollectionViewCell.swift
//  NormalizedHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/08/14.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {

    @IBOutlet var container: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!

    @IBOutlet var imageAspectConstraint: NSLayoutConstraint!
    @IBOutlet var imageWidthConstraint: NSLayoutConstraint!

    @IBOutlet var imageVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet var labelsVerticalConstraints: [NSLayoutConstraint]!
    @IBOutlet var imageSideConstraints: [NSLayoutConstraint]!
    @IBOutlet var topLabelSideConstraints: [NSLayoutConstraint]!
    @IBOutlet var leftRightLabelsSideConstraints: [NSLayoutConstraint]!

    lazy var imageWidth: CGFloat = { return self.imageWidthConstraint.constant }()
    lazy var imageSidePadding: CGFloat = { return self.imageSideConstraints.getConstantsSum() }()
    lazy var imageVerticalPadding: CGFloat = { return self.imageVerticalConstraints.getConstantsSum() }()
    lazy var topLabelSidePadding: CGFloat = { return self.topLabelSideConstraints.getConstantsSum() }()
    lazy var leftRightLabelsSidePadding: CGFloat = { return self.leftRightLabelsSideConstraints.getConstantsSum() }()
    lazy var labelsVerticalPadding: CGFloat = { return self.labelsVerticalConstraints.getConstantsSum() }()

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
}

extension ListCollectionViewCell: HeightCalculable {

    func heightForWidth<T>(width: CGFloat, model: T) -> CGFloat {
        guard let model = model as? CellModel else {
            return 0.0
        }
        let imageHeight = imageWidth * imageAspectConstraint.multiplier + imageVerticalPadding
        let leftSum = imageHeight

        let labelWidth = width - topLabelSidePadding - imageWidth - imageSidePadding
        let labelHeight = TextHeightCalculator.calculate(for:
            (text: model.topText, font: topLabel.font, width: labelWidth)
        )
        let label2Width = (width - leftRightLabelsSidePadding - imageWidth - imageSidePadding) / 2
        let bottomLabelHeight = TextHeightCalculator.calculateMax(for: [
            (text: model.leftText, font: leftLabel.font, width: label2Width),
            (text: model.rightText, font: rightLabel.font, width: label2Width)
            ])
        let rightSum = labelHeight + bottomLabelHeight + labelsVerticalPadding

        let sum = max(leftSum, rightSum)
        return sum
    }

}
