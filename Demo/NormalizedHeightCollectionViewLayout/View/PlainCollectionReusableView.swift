//
//  PlainCollectionReusableView.swift
//  NormalizedHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/08/14.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

//class AnimatableLayoutAttributes: UICollectionViewLayoutAttributes {
//    var animationHandler: ((UIView) -> Void)?
//}

class PlainCollectionReusableView: UICollectionReusableView {

//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        if let animatableLayoutAttributes = layoutAttributes as? AnimatableLayoutAttributes {
//            print(self)
////            subviews.first!.backgroundColor = UIColor.red
//
//            animatableLayoutAttributes.animationHandler?(self)
//        }
////        super.apply(layoutAttributes)
//    }

    override func willTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        super.willTransition(from: oldLayout, to: newLayout)
        alpha = 0
    }

    override func didTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        super.didTransition(from: oldLayout, to: newLayout)
        alpha = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
    }

}
