//
//  Array+Extension.swift
//  DynamicHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/11.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

extension Array where Element: NSLayoutConstraint {

    func getConstantsSum() -> CGFloat {
        let sum = map { constraint in
            return constraint.constant
            }
            .reduce(0) { lhs, rhs in
                return lhs + rhs
        }
        return sum
    }

}
