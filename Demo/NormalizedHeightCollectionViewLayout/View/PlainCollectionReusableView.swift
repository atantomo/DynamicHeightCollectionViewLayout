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

    var animateHandler: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(animate(sender:)), name: Resources.NotificationName.animateDecoration, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(animate(sender:)), name: Resources.NotificationName.animateDecoration, object: nil)
    }

    @objc
    func animate(sender: Notification) {
        animateHandler?()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
//        alpha = 0
//        animateHandler = {
//            UIView.animate(withDuration: 1, delay: 3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//                self.subviews.first?.backgroundColor = UIColor.red
//            })
//        }
        animateHandler = { [weak self] in
            self?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self?.alpha = 1
            }
        }
    }

    override func willTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        super.willTransition(from: oldLayout, to: newLayout)
        alpha = 0
    }
//
//    override func didTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
//        super.didTransition(from: oldLayout, to: newLayout)
//        alpha = 0
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.alpha = 1
//        }
//    }

}
