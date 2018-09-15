//
//  RoundedButton.swift
//  DynamicHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/08/14.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func configureCornerRadius(radius: CGFloat = 4) {
        layer.cornerRadius = radius
    }

    private func commonInit() {
        configureCornerRadius()
    }

}
