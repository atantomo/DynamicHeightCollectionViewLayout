//
//  SampleEntity.swift
//  DynamicHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/11.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

struct CellModel {
    var topText: String
    var leftText: String
    var rightText: String
}

struct SampleEntity {

    static let sampleText: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat"

    static var explodedSampleText: [String] = {
        return SampleEntity.sampleText.components(separatedBy: " ")
    }()

    static var textCounts: [(Int, Int, Int)] = [
        (2, 1, 1),
        (3, 3, 3),
        (5, 12, 7),
        (7, 5, 6),
        (9, 7, 15),
        (1, 9, 9),
        (3, 1, 4),
        (4, 4, 1),
        (10, 8, 6)
    ]

    static var models: [CellModel] = {
        var models = [CellModel]()
        let joinUpTo = { (length: Int) -> String in
            return SampleEntity.explodedSampleText[0..<length].joined(separator: " ")
        }
        for i in 0..<SampleEntity.textCounts.count {
            let topText = joinUpTo(SampleEntity.textCounts[i].0)
            let leftText = joinUpTo(SampleEntity.textCounts[i].1)
            let rightText = joinUpTo(SampleEntity.textCounts[i].2)

            let model = CellModel(topText: topText, leftText: leftText, rightText: rightText)
            models.append(model)
        }
        return models
    }()
}

