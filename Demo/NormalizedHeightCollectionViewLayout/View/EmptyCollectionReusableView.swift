//
//  EmptyCollectionReusableView.swift
//  NormalizedHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/08/14.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

class EmptyCollectionReusableView: UICollectionReusableView {

    override func willTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        super.willTransition(from: oldLayout, to: newLayout)
        alpha = 0
    }

    override func didTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        super.didTransition(from: oldLayout, to: newLayout)
        alpha = 1
    }

}
