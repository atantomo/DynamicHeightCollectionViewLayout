//
//  Resources.swift
//  DynamicHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/13.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

struct Resources {

    struct Image {
        static let grid: UIImage = UIImage(named: "icon-grid")!
        static let list: UIImage = UIImage(named: "icon-list")!
    }

    struct Color {
        static let normalCellBackground: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        static let highlightedCellBackground: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    }

    struct NotificationName {
        static let deleteCell: NSNotification.Name = NSNotification.Name(rawValue: "deleteCell")
        static let updateCell: NSNotification.Name = NSNotification.Name(rawValue: "updateCell")
    }

}
