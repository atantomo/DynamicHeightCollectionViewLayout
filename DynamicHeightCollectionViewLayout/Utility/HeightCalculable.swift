//
//  HeightCalculable.swift
//  DynamicHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/11.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

protocol HeightCalculable {
    associatedtype T
    func heightForWidth(width: CGFloat, model: T) -> CGFloat
}
