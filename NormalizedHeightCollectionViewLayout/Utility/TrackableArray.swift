//
//  TrackableArray.swift
//  NormalizedHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/11.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import Foundation

struct TrackableArray<T> {

    enum Change {
        case set
        case insert([Int])
        case delete([Int])
    }

    private (set) var latestChange: Change = Change.set
    private (set) var array: [T] = []

    init(_ array: [T] = []) {
        self.array = array
    }

    mutating func append(_ element: T) {
        let addIndex = self.array.count

        latestChange = Change.insert([addIndex])
        self.array.append(element)
    }

    mutating func append(contentsOf array: [T]) {
        let startAddIndex = self.array.count
        let endAddIndex = startAddIndex + array.count - 1

        latestChange = Change.insert(Array(startAddIndex...endAddIndex))
        self.array.append(contentsOf: array)
    }

    mutating func remove(at index: Int) {
        latestChange = Change.delete([index])
        self.array.remove(at: index)
    }

    mutating func remove(at indexes: [Int]) {
        let sortedReversedIndexes = Array(indexes.sorted().reversed())

        latestChange = Change.delete(sortedReversedIndexes)
        for index in sortedReversedIndexes {
            self.array.remove(at: index)
        }
    }

}

extension TrackableArray: Collection {

    typealias Index = Int
    typealias Element = T

    var startIndex: Index {
        return array.startIndex
    }

    var endIndex: Index {
        return array.endIndex
    }

    subscript(index: Index) -> T {
        return array[index]
    }

    func index(after i: Index) -> Index {
        return array.index(after: i)
    }

}

extension TrackableArray: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: Element...) {
        array = elements
    }

}
